import 'dart:ui';

import 'package:audiobook_app/core/extensions/empty_padding.dart';
import 'package:audiobook_app/core/extensions/num_duration_extension.dart';
import 'package:audiobook_app/data/models/audiobook.dart';
import 'package:audiobook_app/ui/widgets/audio_player_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AudiobookScreen extends StatefulWidget {
  final Audiobook audiobook;
  final int initialIndex;
  const AudiobookScreen({super.key, required this.audiobook, required this.initialIndex});

  @override
  State<AudiobookScreen> createState() => _AudiobookScreenState();
}

class _AudiobookScreenState extends State<AudiobookScreen> {
  final CarouselController _titleController = CarouselController();
  final CarouselController _coverController = CarouselController();
  final CarouselController _backgroundController = CarouselController();
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  _changeIndex(int index) {
    if (mounted) {
      _titleController.animateToPage(index, duration: 200.ms, curve: Curves.easeOutQuart);
      _coverController.animateToPage(index, duration: 200.ms, curve: Curves.easeOutQuart);
      _backgroundController.animateToPage(index, duration: 200.ms, curve: Curves.easeOutQuart);
      setState(() => currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider.builder(
              options: CarouselOptions(
                initialPage: currentIndex,
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1,
                scrollPhysics: const NeverScrollableScrollPhysics(),
              ),
              disableGesture: true,
              carouselController: _backgroundController,
              itemCount: audiobooks.length,
              itemBuilder: (context, index, realIndex) {
                return Image.asset(
                  audiobooks[index].bookCover,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: Colors.black26,
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        initialPage: currentIndex,
                        height: MediaQuery.of(context).size.height,
                        viewportFraction: 1,
                        scrollPhysics: const NeverScrollableScrollPhysics(),
                      ),
                      disableGesture: true,
                      carouselController: _titleController,
                      itemCount: audiobooks.length,
                      itemBuilder: (context, index, realIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            children: [
                              32.ph,
                              Text(
                                audiobooks[index].title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              12.ph,
                              Text(
                                audiobooks[index].author,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xfff3f3f3),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  36.ph,
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: (MediaQuery.of(context).size.width) - 64,
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        initialPage: currentIndex,
                        height: MediaQuery.of(context).size.height,
                        viewportFraction: 1,
                        scrollPhysics: const NeverScrollableScrollPhysics(),
                      ),
                      disableGesture: true,
                      carouselController: _coverController,
                      itemCount: audiobooks.length,
                      itemBuilder: (context, index, realIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              audiobooks[index].bookCover,
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  36.ph,
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          width: MediaQuery.of(context).size.width,
                          // height: (MediaQuery.of(context).size.width - 64) * .7,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            clipBehavior: Clip.antiAlias,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: AudioPlayerWidget(
                                  index: currentIndex,
                                  changeIndex: _changeIndex,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  36.ph,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
