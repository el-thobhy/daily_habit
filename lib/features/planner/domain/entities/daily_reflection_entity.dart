import 'package:equatable/equatable.dart';

class DailyReflectionEntity extends Equatable {
  final String id;
  final DateTime date;
  final String todayLesson;
  final String memorableNotes;
  final int moodRating;
  final String userId;

  const DailyReflectionEntity({
    required this.id,
    required this.date,
    this.todayLesson = '',
    this.memorableNotes = '',
    this.moodRating = 5,
    this.userId = '',
  });

  DailyReflectionEntity copyWith({
    String? id,
    DateTime? date,
    String? todayLesson,
    String? memorableNotes,
    int? moodRating,
    String? userId,
  }) {
    return DailyReflectionEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      todayLesson: todayLesson ?? this.todayLesson,
      memorableNotes: memorableNotes ?? this.memorableNotes,
      moodRating: moodRating ?? this.moodRating,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    todayLesson,
    memorableNotes,
    moodRating,
    userId,
  ];
}
