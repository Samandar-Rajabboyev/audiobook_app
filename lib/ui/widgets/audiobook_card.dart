import 'package:audiobook_app/core/extensions/empty_padding.dart';
import 'package:audiobook_app/core/extensions/num_duration_extension.dart';
import 'package:audiobook_app/core/router/app_routes.dart';
import 'package:audiobook_app/data/models/audiobook.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../audio_player.dart';
import '../../bloc/audiobooks_cubit.dart';

class AudiobookCard extends StatefulWidget {
  final Audiobook audiobook;
  final int index;

  const AudiobookCard({super.key, required this.audiobook, required this.index});

  @override
  State<AudiobookCard> createState() => _AudiobookCardState();
}

class _AudiobookCardState extends State<AudiobookCard> {
  final audioPlayer = AppAudioPlayer();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
        stream: audioPlayer.playlistStream,
        builder: (context, indexStream) {
          return BlocBuilder<AudiobooksCubit, AudiobooksState>(
            builder: (context, state) {
              return Stack(
                children: [
                  Bounceable(
                    scaleFactor: .9,
                    duration: 100.ms,
                    reverseDuration: 100.ms,
                    onTap: () {
                      Future.delayed(100.ms).then((value) {
                        context.goNamed(
                          AppRoutes.audiobook.name,
                          extra: widget.audiobook,
                          pathParameters: {'index': '${widget.index}'},
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          if (indexStream.data == widget.index)
                            BoxShadow(
                              color: widget.audiobook.color.withOpacity(.1),
                              blurRadius: 7,
                              offset: const Offset(0, 2),
                              spreadRadius: 2,
                            ),
                          const BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 3,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  widget.audiobook.bookCover,
                                  width: 66,
                                  height: 66,
                                ),
                              ),
                              12.pw,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.audiobook.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        height: 1,
                                      ),
                                    ),
                                    6.ph,
                                    Text(
                                      widget.audiobook.author,
                                      style: const TextStyle(
                                        color: Color(0xFF2D2E33),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              12.pw,
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: BlocBuilder<AudiobooksCubit, AudiobooksState>(
                                  builder: (context, state) {
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: CircularProgressIndicator(
                                            value: widget.audiobook.localPath != null
                                                ? 1
                                                : (state.progresses
                                                        .firstWhereOrNull(
                                                            (element) => element.id == widget.audiobook.title)
                                                        ?.progress ??
                                                    0),
                                            strokeWidth: 2,
                                            strokeCap: StrokeCap.round,
                                            color: widget.audiobook.color,
                                            strokeAlign: BorderSide.strokeAlignOutside,
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: widget.audiobook.localPath != null
                                              ? () {}
                                              : () {
                                                  context
                                                      .read<AudiobooksCubit>()
                                                      .download(widget.audiobook.url, widget.audiobook.title);
                                                },
                                          height: 48,
                                          elevation: 0,
                                          disabledElevation: 0,
                                          focusElevation: 0,
                                          highlightElevation: 0,
                                          hoverElevation: 0,
                                          color: const Color(0xfff3f3f3),
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.all(12),
                                          shape: const OvalBorder(
                                            side: BorderSide(
                                              color: Color(0x71dadada),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              CupertinoIcons.arrow_down,
                                              color: Color(0x71232323),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          12.ph,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.audiobook.summary,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF32424D),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              21.pw,
                              Align(
                                alignment: Alignment.bottomRight,
                                child: SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: StreamBuilder<PlayerState>(
                                      stream: audioPlayer.playerStateStream,
                                      builder: (context, playerState) {
                                        return MaterialButton(
                                          onPressed: () {
                                            if ((playerState.data?.playing ?? true)
                                                ? indexStream.data != widget.index
                                                : true) {
                                              audioPlayer.play(widget.index);
                                            } else {
                                              audioPlayer.pause();
                                            }
                                          },
                                          height: 48,
                                          elevation: 0,
                                          disabledElevation: 0,
                                          focusElevation: 0,
                                          highlightElevation: 0,
                                          hoverElevation: 0,
                                          color: const Color(0xfff3f3f3),
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.all(12),
                                          shape: const OvalBorder(
                                            side: BorderSide(
                                              color: Color(0x71dadada),
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              CupertinoIcons.playpause,
                                              color: indexStream.data == widget.index
                                                  ? widget.audiobook.color
                                                  : const Color(0x71232323),
                                              size: 24,
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!state.hasInternet && widget.audiobook.localPath == null)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withOpacity(.4),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        });
  }
}
