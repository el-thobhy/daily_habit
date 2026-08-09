import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';

class DailyReflectionModel {
  final String id;
  final String dateIso;
  final String todayLesson;
  final String memorableNotes;
  final int moodRating;

  DailyReflectionModel({
    required this.id,
    required this.dateIso,
    required this.todayLesson,
    required this.memorableNotes,
    required this.moodRating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateIso': dateIso,
      'todayLesson': todayLesson,
      'memorableNotes': memorableNotes,
      'moodRating': moodRating,
    };
  }

  factory DailyReflectionModel.fromMap(Map<dynamic, dynamic> map) {
    return DailyReflectionModel(
      id: map['id'] as String,
      dateIso: map['dateIso'] as String,
      todayLesson: map['todayLesson'] as String? ?? '',
      memorableNotes: map['memorableNotes'] as String? ?? '',
      moodRating: map['moodRating'] as int? ?? 5,
    );
  }

  DailyReflectionEntity toEntity() {
    return DailyReflectionEntity(
      id: id,
      date: DateTime.parse(dateIso),
      todayLesson: todayLesson,
      memorableNotes: memorableNotes,
      moodRating: moodRating,
    );
  }

  factory DailyReflectionModel.fromEntity(DailyReflectionEntity entity) {
    final dateStr = "${entity.date.year.toString().padLeft(4, '0')}-${entity.date.month.toString().padLeft(2, '0')}-${entity.date.day.toString().padLeft(2, '0')}";
    return DailyReflectionModel(
      id: entity.id,
      dateIso: dateStr,
      todayLesson: entity.todayLesson,
      memorableNotes: entity.memorableNotes,
      moodRating: entity.moodRating,
    );
  }
}
