import 'package:equatable/equatable.dart';

class DailyReflectionEntity extends Equatable {
  final String id;
  final DateTime date;
  final String todayLesson;
  final String memorableNotes;
  final int moodRating;

  const DailyReflectionEntity({
    required this.id,
    required this.date,
    this.todayLesson = '',
    this.memorableNotes = '',
    this.moodRating = 5,
  });

  DailyReflectionEntity copyWith({
    String? id,
    DateTime? date,
    String? todayLesson,
    String? memorableNotes,
    int? moodRating,
  }) {
    return DailyReflectionEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      todayLesson: todayLesson ?? this.todayLesson,
      memorableNotes: memorableNotes ?? this.memorableNotes,
      moodRating: moodRating ?? this.moodRating,
    );
  }

  @override
  List<Object?> get props => [id, date, todayLesson, memorableNotes, moodRating];
}
