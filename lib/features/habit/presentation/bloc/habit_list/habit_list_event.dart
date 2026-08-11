import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:equatable/equatable.dart';

abstract class HabitListEvent extends Equatable {
  const HabitListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayHabitsEvent extends HabitListEvent {
  final DateTime? date;
  const LoadTodayHabitsEvent({this.date});

  @override
  List<Object?> get props => [date];
}

class ToggleHabitCompletionEvent extends HabitListEvent {
  final String habitId;

  const ToggleHabitCompletionEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class AddHabitEvent extends HabitListEvent {
  final HabitEntity habit;

  const AddHabitEvent(this.habit);

  @override
  List<Object?> get props => [habit];
}

class UpdateHabitEvent extends HabitListEvent {
  final HabitEntity habit;

  const UpdateHabitEvent(this.habit);

  @override
  List<Object?> get props => [habit];
}

class ArchiveHabitEvent extends HabitListEvent {
  final String habitId;

  const ArchiveHabitEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class UnarchiveHabitEvent extends HabitListEvent {
  final String habitId;

  const UnarchiveHabitEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}
