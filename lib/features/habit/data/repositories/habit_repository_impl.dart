import 'package:daily_habit/features/habit/data/datasources/habit_local_datasource.dart';
import 'package:daily_habit/features/habit/data/models/model_mappers.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_log_entity.dart';
import 'package:daily_habit/features/habit/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl({required this.localDataSource});

  @override
  Future<void> createHabit(HabitEntity habit) async {
    await localDataSource.createHabit(HabitDataModelX.fromEntity(habit));
  }

  @override
  List<HabitEntity> getAllHabits({bool includeArchived = false}) {
    final models = localDataSource.getAllHabits(includeArchived: includeArchived);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  List<HabitEntity> getHabitsForToday() {
    final models = localDataSource.getHabitsForToday();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    await localDataSource.updateHabit(HabitDataModelX.fromEntity(habit));
  }

  @override
  Future<void> archiveHabit(String id) async {
    await localDataSource.archiveHabit(id);
  }

  @override
  Future<void> unarchiveHabit(String id) async {
    await localDataSource.unarchiveHabit(id);
  }

  @override
  Future<void> logHabit({
    required String habitId,
    required bool completed,
    int countValue = 1,
    String? note,
  }) async {
    await localDataSource.logHabit(
      habitId: habitId,
      completed: completed,
      countValue: countValue,
      note: note,
    );
  }

  @override
  HabitLogEntity? getLogForDate(String habitId, DateTime date) {
    final log = localDataSource.getLogForDate(habitId, date);
    return log?.toEntity();
  }

  @override
  List<HabitLogEntity> getLogForHabit(String habitId, {int? limit}) {
    final logs = localDataSource.getLogForHabit(habitId, limit: limit);
    return logs.map((l) => l.toEntity()).toList();
  }

  @override
  List<HabitLogEntity?> getLogsForDate(DateTime date) {
    final logs = localDataSource.getLogsForDate(date);
    return logs.map((l) => l?.toEntity()).toList();
  }

  @override
  Map<String, dynamic> getStatsForRange(DateTime start, DateTime end) {
    return localDataSource.getStatsForRange(start, end);
  }

  @override
  int calculateStreak(String habitId) {
    return localDataSource.calculateStreak(habitId);
  }

  @override
  Future<void> clearAll() async {
    await localDataSource.clearAll();
  }
}
