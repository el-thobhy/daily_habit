// lib/models/habit_model.dart
import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final int streak;
  final bool isCompleted;
  final List<int> frequency; // 1-7 for days of week
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.streak = 0,
    this.isCompleted = false,
    required this.frequency,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    Color? color,
    int? streak,
    bool? isCompleted,
    List<int>? frequency,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      streak: streak ?? this.streak,
      isCompleted: isCompleted ?? this.isCompleted,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}