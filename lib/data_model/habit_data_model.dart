import 'package:hive_flutter/hive_flutter.dart';

part 'habit_data_model.g.dart';

@HiveType(typeId: 0)
class HabitDataModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String emoji;

  @HiveField(3)
  int colorValue; // Store as int, not hex string

  @HiveField(4)
  List<int> frequency; // [1,2,3,4,5,6,7]

  @HiveField(5)
  String? reminderTime; // "08:00"

  @HiveField(6)
  int targetCount;

  @HiveField(7)
  String? unit;

  @HiveField(8)
  String? categoryId;

  @HiveField(9)
  int sortOrder;

  @HiveField(10)
  bool isArchived;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

   HabitDataModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    this.frequency = const [1, 2, 3, 4, 5, 6, 7],
    this.reminderTime,
    this.targetCount = 1,
    this.unit,
    this.categoryId,
    this.sortOrder = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });
}