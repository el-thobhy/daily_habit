import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final int colorValue;
  final List<int> frequency;
  final String? reminderTime;
  final int targetCount;
  final String? unit;
  final String? categoryId;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;

  const HabitEntity({
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
    this.userId,
  });

  HabitEntity copyWith({
    String? id,
    String? name,
    String? emoji,
    int? colorValue,
    List<int>? frequency,
    String? reminderTime,
    int? targetCount,
    String? unit,
    String? categoryId,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      targetCount: targetCount ?? this.targetCount,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        emoji,
        colorValue,
        frequency,
        reminderTime,
        targetCount,
        unit,
        categoryId,
        sortOrder,
        isArchived,
        createdAt,
        updatedAt,
        userId,
      ];
}
