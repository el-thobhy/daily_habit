import 'package:daily_habit/data_model/habit_data_model.dart';
import 'package:daily_habit/data_model/habit_log_model.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_log_entity.dart';

extension HabitDataModelX on HabitDataModel {
  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      name: name,
      emoji: emoji,
      colorValue: colorValue,
      frequency: frequency,
      reminderTime: reminderTime,
      targetCount: targetCount,
      unit: unit,
      categoryId: categoryId,
      sortOrder: sortOrder,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
    );
  }

  static HabitDataModel fromEntity(HabitEntity entity) {
    return HabitDataModel(
      id: entity.id,
      name: entity.name,
      emoji: entity.emoji,
      colorValue: entity.colorValue,
      frequency: entity.frequency,
      reminderTime: entity.reminderTime,
      targetCount: entity.targetCount,
      unit: entity.unit,
      categoryId: entity.categoryId,
      sortOrder: entity.sortOrder,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
    );
  }
}

extension HabitLogModelX on HabitLogModel {
  HabitLogEntity toEntity() {
    return HabitLogEntity(
      id: id,
      habitId: habitId,
      date: date,
      completed: completed,
      countValue: countValue,
      note: note,
      completedAt: completedAt,
      createdAt: createdAt,
      userId: userId,
    );
  }

  static HabitLogModel fromEntity(HabitLogEntity entity) {
    return HabitLogModel(
      id: entity.id,
      habitId: entity.habitId,
      date: entity.date,
      completed: entity.completed,
      countValue: entity.countValue,
      note: entity.note,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
      userId: entity.userId,
    );
  }
}
