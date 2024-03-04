import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audiobook_app/core/constants/app_constants.dart';
import 'package:audiobook_app/core/service/prefs.dart';
import 'package:audiobook_app/data/models/audiobook.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AppAudioPlayer {
  final _audioPlayer = AudioPlayer();
  ConcatenatingAudioSource? playlist;

  static final AppAudioPlayer _singleton = AppAudioPlayer._internal();

  factory AppAudioPlayer() {
    return _singleton;
  }

  AppAudioPlayer._internal() {
    init();
  }

  Future<void> init({int? initialIndex, Duration? initialPosition, List<Audiobook>? audiobooks}) async {
    initialIndex ??= await Prefs.getInt(AppConstants.kLastIndexKey);
    initialPosition ??= Duration(milliseconds: await Prefs.getInt(AppConstants.kLastPositionOfAudioKey) ?? 0);
    log("index: $initialIndex\nposition: $initialPosition");
    playlist = await _playlist(audiobooks);
    if (playlist != null) {
      await _audioPlayer.setAudioSource(
        playlist!,
        initialIndex: initialIndex,
        initialPosition: initialPosition,
      );
    }
    await _audioPlayer.setShuffleModeEnabled(false);
    await _audioPlayer.setLoopMode(LoopMode.all);
  }

  Future<ConcatenatingAudioSource> _playlist([List<Audiobook>? _audiobooks]) async {
    List<AudioSource> _sources = [];

    for (var value in (_audiobooks ?? audiobooks)) {
      _sources.add(value.localPath != null
          ? AudioSource.file(
              value.localPath!,
              tag: MediaItem(
                id: value.url,
                artUri: await _getImageFileFromAssets(value.bookCover, value.title),
                title: value.title,
                artist: value.author,
              ),
            )
          : AudioSource.uri(
              Uri.parse(value.url),
              tag: MediaItem(
                id: value.url,
                artUri: await _getImageFileFromAssets(value.bookCover, value.title),
                title: value.title,
                artist: value.author,
              ),
            ));
    }

    return ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: _sources,
    );
  }

  Future<void> play(int index, [Duration? position]) async {
    if (_audioPlayer.currentIndex != index) {
      await _audioPlayer.seek(position ?? Duration.zero, index: index);
    }
    await _audioPlayer.play();

    _audioPlayer.currentIndexStream.listen((event) async {
      bool hasConnection = await InternetConnectionChecker().hasConnection;
      if (hasConnection) Prefs.setInt(AppConstants.kLastIndexKey, event ?? 0);
    });
    _audioPlayer.positionStream.listen((event) async {
      bool hasConnection = await InternetConnectionChecker().hasConnection;
      if (hasConnection) Prefs.setInt(AppConstants.kLastPositionOfAudioKey, event.inMilliseconds);
    });
  }

  Future<void> setLoopMode(LoopMode loopMode) => _audioPlayer.setLoopMode(loopMode);
  Future<void> shuffle(bool enable) async {
    if (enable) _audioPlayer.shuffle();
    _audioPlayer.setShuffleModeEnabled(enable);
  }

  Future<void> pause() async => _audioPlayer.pause();
  Future<void> resume() async => _audioPlayer.play();
  Future<void> stop() async => _audioPlayer.stop();
  Future<void> seek(Duration position) async => _audioPlayer.seek(position);
  Duration? get duration => _audioPlayer.duration;
  Duration? get position => _audioPlayer.position;
  List<int>? get shuffleIndices => _audioPlayer.shuffleIndices;
  bool? get isShuffled => _audioPlayer.shuffleModeEnabled;
  int? get currentIndex => _audioPlayer.currentIndex;

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<int?> get playlistStream => _audioPlayer.currentIndexStream;
  Stream<LoopMode> get loopModeStream => _audioPlayer.loopModeStream;
  Stream<Duration> get playerDurationStream => _audioPlayer.positionStream;

  static Future<Uri> _getImageFileFromAssets(String src, String title) async {
    final byteData = await rootBundle.load(src);
    final buffer = byteData.buffer;
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var filePath = '$tempPath/art_$title.png'; // file_01.tmp is dump file, can be anything
    return (await File(filePath).writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes))).uri;
  }
}
