import 'package:daily_habit/core/usecase/usecase.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:daily_habit/features/habit/domain/repositories/habit_repository.dart';

class GetHabitsForToday implements UseCase<List<HabitEntity>, DateTime?> {
  final HabitRepository repository;

  GetHabitsForToday(this.repository);

  @override
  Future<List<HabitEntity>> call(DateTime? date) async {
    return repository.getHabitsForToday(date: date);
  }
}

class GetAllHabits implements UseCase<List<HabitEntity>, bool> {
  final HabitRepository repository;

  GetAllHabits(this.repository);

  @override
  Future<List<HabitEntity>> call(bool includeArchived) async {
    return repository.getAllHabits(includeArchived: includeArchived);
  }
}

class CreateHabit implements UseCase<void, HabitEntity> {
  final HabitRepository repository;

  CreateHabit(this.repository);

  @override
  Future<void> call(HabitEntity habit) async {
    return repository.createHabit(habit);
  }
}

class UpdateHabit implements UseCase<void, HabitEntity> {
  final HabitRepository repository;

  UpdateHabit(this.repository);

  @override
  Future<void> call(HabitEntity habit) async {
    return repository.updateHabit(habit);
  }
}

class ArchiveHabit implements UseCase<void, String> {
  final HabitRepository repository;

  ArchiveHabit(this.repository);

  @override
  Future<void> call(String habitId) async {
    return repository.archiveHabit(habitId);
  }
}

class UnarchiveHabit implements UseCase<void, String> {
  final HabitRepository repository;

  UnarchiveHabit(this.repository);

  @override
  Future<void> call(String habitId) async {
    return repository.unarchiveHabit(habitId);
  }
}

class LogHabitParams {
  final String habitId;
  final bool completed;
  final int countValue;
  final String? note;
  final DateTime? date;

  LogHabitParams({
    required this.habitId,
    required this.completed,
    this.countValue = 1,
    this.note,
    this.date,
  });
}

class LogHabit implements UseCase<void, LogHabitParams> {
  final HabitRepository repository;

  LogHabit(this.repository);

  @override
  Future<void> call(LogHabitParams params) async {
    return repository.logHabit(
      habitId: params.habitId,
      completed: params.completed,
      countValue: params.countValue,
      note: params.note,
      date: params.date,
    );
  }
}

class CalculateStreak implements UseCase<int, String> {
  final HabitRepository repository;

  CalculateStreak(this.repository);

  @override
  Future<int> call(String habitId) async {
    return repository.calculateStreak(habitId);
  }
}
