import 'dart:developer';

import 'package:audiobook_app/audio_player.dart';
import 'package:audiobook_app/core/extensions/empty_padding.dart';
import 'package:audiobook_app/core/extensions/num_duration_extension.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../bloc/audiobooks_cubit.dart';
import '../../data/models/audiobook.dart';

class AudioPlayerWidget extends StatefulWidget {
  final int index;
  final Function(int index) changeIndex;

  const AudioPlayerWidget({
    super.key,
    required this.index,
    required this.changeIndex,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;
  final audioPlayer = AppAudioPlayer();

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(vsync: this, duration: 200.ms);
    _iconAnimation = Tween<double>(begin: 1, end: 0).animate(_iconAnimationController);
    audioPlayer.play(widget.index);
    audioPlayer.playlistStream.listen((event) {
      widget.changeIndex(event ?? 0);
    });
    audioPlayer.playerStateStream.listen((event) {
      if (event.playing) {
        _iconAnimationController.reverse();
      } else {
        _iconAnimationController.forward();
      }
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  _onChangeMode(LoopMode? data) {
    if (data == LoopMode.off) {
      audioPlayer.setLoopMode(LoopMode.all);
      audioPlayer.shuffle(false);
    } else if (data == LoopMode.all) {
      audioPlayer.setLoopMode(LoopMode.one);
    } else if (data == LoopMode.one) {
      audioPlayer.setLoopMode(LoopMode.off);
      audioPlayer.shuffle(true);
    }
  }

  _onPlayPause(bool playing) {
    if (playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.resume();
    }
  }

  _onDownload() {
    Audiobook audiobook = audiobooks[widget.index];
    context.read<AudiobooksCubit>().download(audiobook.url, audiobook.title);
  }

  @override
  Widget build(BuildContext context) {
    Audiobook audiobook = audiobooks[widget.index];
    return StreamBuilder<PlayerState>(
        stream: audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<Duration>(
                  stream: audioPlayer.playerDurationStream,
                  builder: (context, snapshot) {
                    double sliderValue =
                        ((snapshot.data?.inMilliseconds ?? 1) / (audioPlayer.duration?.inMilliseconds ?? 1));
                    if (sliderValue < 0) {
                      sliderValue = 0;
                    } else if (sliderValue > 1.0) {
                      sliderValue = 1.0;
                    }

                    return Column(
                      children: [
                        Text(
                          "${formatTime(snapshot.data ?? Duration.zero)} / ${formatTime(audioPlayer.duration ?? Duration.zero)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Slider(
                          value: sliderValue,
                          activeColor: audiobook.color,
                          onChanged: (value) {
                            audioPlayer.seek(
                              Duration(
                                milliseconds: ((audioPlayer.duration?.inMilliseconds ?? 1) * value).toInt(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                6.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // [ shuffle| repeat all | repeat one ] button
                    StreamBuilder<LoopMode>(
                        stream: audioPlayer.loopModeStream,
                        builder: (context, snapshot) {
                          return _icon(
                            onPressed: () {
                              _onChangeMode(snapshot.data);
                            },
                            color: Colors.transparent,
                            child: Icon(
                              snapshot.data == LoopMode.off
                                  ? Icons.shuffle_rounded
                                  : (snapshot.data == LoopMode.all ? Icons.repeat_rounded : Icons.repeat_one_rounded),
                              color: Colors.white,
                              size: 21,
                            ),
                          );
                        }),
                    8.pw,
                    // previous button
                    _icon(
                      onPressed: () {
                        audioPlayer.play(widget.index == 0 ? audiobooks.length - 1 : (widget.index - 1));
                      },
                      color: Colors.transparent,
                      child: const Icon(
                        Icons.skip_previous_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    12.pw,
                    // play|pause button
                    _icon(
                      onPressed: () {
                        _onPlayPause(snapshot.data?.playing ?? false);
                      },
                      size: 64,
                      color: audiobook.color.withOpacity(.6),
                      child: snapshot.data?.processingState == ProcessingState.loading
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              color: Colors.white,
                              size: 28,
                              progress: _iconAnimation,
                            ),
                    ),
                    12.pw,

                    // next button
                    _icon(
                      onPressed: () {
                        log('shuffle - ${audioPlayer.isShuffled} - ${audioPlayer.shuffleIndices}');
                        int index = widget.index == (audiobooks.length - 1) ? 0 : (widget.index + 1);
                        audioPlayer.play(index);
                      },
                      color: Colors.transparent,
                      child: const Icon(
                        Icons.skip_next_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    8.pw,
                    // download button
                    BlocBuilder<AudiobooksCubit, AudiobooksState>(
                      builder: (context, state) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: audiobooks[widget.index].localPath != null
                                    ? 1
                                    : (state.progresses
                                            .firstWhereOrNull((element) => element.id == audiobooks[widget.index].title)
                                            ?.progress ??
                                        0),
                                strokeWidth: 10,
                                strokeCap: StrokeCap.round,
                                color: audiobooks[widget.index].color,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                            _icon(
                              onPressed: audiobooks[widget.index].localPath != null ? () {} : _onDownload,
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget _icon({
    required Function() onPressed,
    double size = 48,
    required Color color,
    required Widget child,
  }) {
    return SizedBox(
      height: size,
      width: size,
      child: MaterialButton(
        onPressed: onPressed,
        elevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        disabledElevation: 0,
        color: color,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90),
        ),
        child: child,
      ),
    );
  }
}
