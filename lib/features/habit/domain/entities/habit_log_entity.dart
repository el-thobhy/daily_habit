import 'package:equatable/equatable.dart';

class HabitLogEntity extends Equatable {
  final String id;
  final String habitId;
  final String date;
  final bool completed;
  final int countValue;
  final String? note;
  final DateTime? completedAt;
  final DateTime createdAt;

  const HabitLogEntity({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.countValue = 0,
    this.note,
    this.completedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        habitId,
        date,
        completed,
        countValue,
        note,
        completedAt,
        createdAt,
      ];
}
