import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_log_entity.dart';

abstract class HabitRepository {
  Future<void> createHabit(HabitEntity habit);
  List<HabitEntity> getAllHabits({bool includeArchived = false});
  List<HabitEntity> getHabitsForToday({DateTime? date});
  Future<void> updateHabit(HabitEntity habit);
  Future<void> archiveHabit(String id);
  Future<void> unarchiveHabit(String id);
  Future<void> logHabit({
    required String habitId,
    required bool completed,
    int countValue = 1,
    String? note,
    DateTime? date,
  });
  HabitLogEntity? getLogForDate(String habitId, DateTime date);
  List<HabitLogEntity> getLogForHabit(String habitId, {int? limit});
  List<HabitLogEntity?> getLogsForDate(DateTime date);
  Map<String, dynamic> getStatsForRange(DateTime start, DateTime end);
  int calculateStreak(String habitId);
  Future<void> clearAll();
}
