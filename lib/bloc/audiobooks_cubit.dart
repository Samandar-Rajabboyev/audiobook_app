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
    Connectivity().onConnectivityChanged.listen((event) async => await checkInternet());
  }

  init() async {
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
      }).then((value) {
        emit(
          state.copyWith(
            progresses: [
              (id: filename, progress: 1),
              ...state.progresses,
            ],
          ),
        );
        AppAudioPlayer().init();
      });
    } catch (e) {
      log("#error2: $e");
    }
  }
}
