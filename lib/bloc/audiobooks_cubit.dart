import 'dart:convert';
import 'dart:developer';

import 'package:audiobook_app/core/constants/app_constants.dart';
import 'package:audiobook_app/core/service/download_manager.dart';
import 'package:audiobook_app/core/service/prefs.dart';
import 'package:audiobook_app/data/models/audiobook.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../audio_player.dart';

part 'audiobooks_state.dart';

class AudiobooksCubit extends Cubit<AudiobooksState> {
  AudiobooksCubit() : super(AudiobooksState()) {
    checkInternet();
    Connectivity().onConnectivityChanged.listen((event) async => await checkInternet());
  }

  init() async {
    await Prefs.getStringList(AppConstants.kPlaylistOrderKey).then((value) {
      if (value != null) {
        audiobooks = [...(value.map((e) => audiobooks.firstWhere((element) => element.id == num.parse(e))))];
      }
    });
    await Prefs.getStringList(AppConstants.kDownloadedFilePathsKey).then((value) {
      if (value != null) {
        for (var i in value) {
          Map<String, dynamic> data = json.decode(i);
          audiobooks.firstWhereOrNull((element) => element.title == data['id'])?.localPath = data['path'];
        }
      }
    });
  }

  Future<void> checkInternet() async {
    bool isConnected = await InternetConnectionChecker().hasConnection;
    if (isConnected) {
      AppAudioPlayer().init();
    } else {
      AppAudioPlayer().init(
        audiobooks: audiobooks.where((element) => element.localPath != null).toList(),
      );
    }
    emit(state.copyWith(hasInternet: isConnected));
  }

  download(String url, String filename) async {
    try {
      emit(
        state.copyWith(
          progresses: [
            (id: filename, progress: 0),
            ...state.progresses,
          ],
        ),
      );
      await DownloadManager.download(url, filename, onProgress: (double progress) {
        emit(state.copyWith(
          progresses: [
            (id: filename, progress: progress),
            ...state.progresses.where((element) => element.id != filename),
          ],
        ));
      }).then((value) async {
        emit(
          state.copyWith(
            progresses: [
              (id: filename, progress: 1),
              ...state.progresses,
            ],
          ),
        );
        await Prefs.getStringList(AppConstants.kDownloadedFilePathsKey).then((value) {
          if (value != null) {
            for (var i in value) {
              Map<String, dynamic> data = json.decode(i);
              audiobooks.firstWhereOrNull((element) => element.title == data['id'])?.localPath = data['path'];
            }
          }
        });
        AppAudioPlayer audioPlayer = AppAudioPlayer();
        audioPlayer.init(initialIndex: audioPlayer.currentIndex, initialPosition: audioPlayer.position);
      });
    } catch (e) {
      log("#error2: $e");
    }
  }
}
