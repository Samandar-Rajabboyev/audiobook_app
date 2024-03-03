part of 'audiobooks_cubit.dart';

class AudiobooksState {
  final List<({String id, double progress})> progresses;
  final bool hasInternet;
  final String errorMessage;

  AudiobooksState({
    this.progresses = const [],
    this.errorMessage = 'Some Error',
    this.hasInternet = true,
  });

  AudiobooksState copyWith({
    List<({String id, double progress})>? progresses,
    bool? hasInternet,
    String? errorMessage,
  }) =>
      AudiobooksState(
        hasInternet: hasInternet ?? this.hasInternet,
        progresses: progresses ?? this.progresses,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
