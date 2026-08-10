// lib/data/models/habit_log_model.dart
import 'package:hive/hive.dart';

part 'habit_log_model.g.dart';

@HiveType(typeId: 1)
class HabitLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String habitId;

  @HiveField(2)
  String date; // "2024-02-28" - YYYY-MM-DD format for easy querying

  @HiveField(3)
  bool completed;

  @HiveField(4)
  int countValue;

  @HiveField(5)
  String? note;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? userId;

  HabitLogModel({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.countValue = 0,
    this.note,
    this.completedAt,
    required this.createdAt,
    this.userId,
  });
}