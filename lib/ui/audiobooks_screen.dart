import 'package:audiobook_app/core/constants/app_constants.dart';
import 'package:audiobook_app/core/service/prefs.dart';
import 'package:audiobook_app/data/models/audiobook.dart';
import 'package:audiobook_app/ui/widgets/audiobook_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../audio_player.dart';
import '../bloc/audiobooks_cubit.dart';

class AudiobooksScreen extends StatefulWidget {
  const AudiobooksScreen({super.key});

  @override
  State<AudiobooksScreen> createState() => _AudiobooksScreenState();
}

class _AudiobooksScreenState extends State<AudiobooksScreen> {
  final audioPlayer = AppAudioPlayer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudiobooksCubit, AudiobooksState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xfff3f3f3),
          appBar: AppBar(
            backgroundColor: const Color(0xfff3f3f3),
            surfaceTintColor: Colors.transparent,
            title: const Text("Audiobooks"),
          ),
          body: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            onReorder: (int oldIndex, int newIndex) {
              if (state.hasInternet) {
                List<Audiobook> oldData = [...audiobooks];
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                audiobooks.insert(newIndex, audiobooks.removeAt(oldIndex));
                Duration? lastPosition = audioPlayer.position;
                if (audioPlayer.currentIndex == oldIndex) {
                  audioPlayer.init(initialIndex: newIndex, initialPosition: lastPosition);
                } else {
                  int i = audiobooks.indexWhere((element) => oldData[audioPlayer.currentIndex ?? 0].id == element.id);
                  audioPlayer.init(initialIndex: i, initialPosition: lastPosition);
                }
                Prefs.setStringList(
                  AppConstants.kPlaylistOrderKey,
                  audiobooks.map((e) => e.id.toString()).toList(),
                );
              }
            },
            itemCount:
                state.hasInternet ? audiobooks.length : audiobooks.where((element) => element.localPath != null).length,
            proxyDecorator: (child, index, animation) => child,
            itemBuilder: (context, index) {
              Audiobook i = state.hasInternet
                  ? audiobooks[index]
                  : audiobooks.where((element) => element.localPath != null).toList()[index];
              return Padding(
                key: ValueKey(index),
                padding: EdgeInsets.only(top: index == 0 ? 0 : 8.0),
                child: AudiobookCard(
                  audiobook: i,
                  index: index,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
