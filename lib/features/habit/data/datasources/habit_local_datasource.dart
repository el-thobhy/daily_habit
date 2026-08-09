import 'package:daily_habit/data_model/habit_data_model.dart';
import 'package:daily_habit/data_model/habit_log_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class HabitLocalDataSource {
  Future<void> init();
  Future<void> createHabit(HabitDataModel habit);
  List<HabitDataModel> getAllHabits({bool includeArchived = false});
  List<HabitDataModel> getHabitsForToday();
  Future<void> updateHabit(HabitDataModel habit);
  Future<void> archiveHabit(String id);
  Future<void> unarchiveHabit(String id);
  Future<void> logHabit({
    required String habitId,
    required bool completed,
    int countValue = 1,
    String? note,
  });
  HabitLogModel? getLogForDate(String habitId, DateTime date);
  List<HabitLogModel> getLogForHabit(String habitId, {int? limit});
  List<HabitLogModel?> getLogsForDate(DateTime date);
  Map<String, dynamic> getStatsForRange(DateTime start, DateTime end);
  int calculateStreak(String habitId);
  Future<void> clearAll();
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  static const String habitsBoxName = 'habits';
  static const String logsBoxName = 'habit_logs';

  late Box<HabitDataModel> _habitsBox;
  late Box<HabitLogModel> _logsBox;

  @override
  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitDataModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HabitLogModelAdapter());
    }

    _habitsBox = await Hive.openBox<HabitDataModel>(habitsBoxName);
    _logsBox = await Hive.openBox<HabitLogModel>(logsBoxName);
  }

  @override
  Future<void> createHabit(HabitDataModel habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  @override
  List<HabitDataModel> getAllHabits({bool includeArchived = false}) {
    final habits = _habitsBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (!includeArchived) {
      return habits.where((h) => !h.isArchived).toList();
    }
    return habits;
  }

  @override
  List<HabitDataModel> getHabitsForToday() {
    final today = DateTime.now().weekday;
    return getAllHabits()
        .where((h) => h.frequency.contains(today))
        .toList();
  }

  @override
  Future<void> updateHabit(HabitDataModel habit) async {
    habit.updatedAt = DateTime.now();
    await _habitsBox.put(habit.id, habit);
  }

  @override
  Future<void> archiveHabit(String id) async {
    final habit = _habitsBox.get(id);
    if (habit != null) {
      habit.isArchived = true;
      await habit.save();
    }
  }

  @override
  Future<void> unarchiveHabit(String id) async {
    final habit = _habitsBox.get(id);
    if (habit != null) {
      habit.isArchived = false;
      await habit.save();
    }
  }

  @override
  Future<void> logHabit({
    required String habitId,
    required bool completed,
    int countValue = 1,
    String? note,
  }) async {
    final today = _formatDate(DateTime.now());
    final existingLog = _logsBox.values.firstWhere(
      (log) => log.habitId == habitId && log.date == today,
      orElse: () => HabitLogModel(
        id: '${habitId}_$today',
        habitId: habitId,
        date: today,
        createdAt: DateTime.now(),
      ),
    );

    existingLog
      ..completed = completed
      ..countValue = countValue
      ..note = note
      ..completedAt = completed ? DateTime.now() : null;

    await _logsBox.put(existingLog.id, existingLog);
  }

  @override
  HabitLogModel? getLogForDate(String habitId, DateTime date) {
    final dateStr = _formatDate(date);
    try {
      return _logsBox.values.firstWhere((log) => log.habitId == habitId && log.date == dateStr);
    } catch (e) {
      return null;
    }
  }

  @override
  List<HabitLogModel> getLogForHabit(String habitId, {int? limit}) {
    final logs = _logsBox.values
        .where((log) => log.habitId == habitId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (limit != null) {
      return logs.take(limit).toList();
    }
    return logs;
  }

  @override
  List<HabitLogModel?> getLogsForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return _logsBox.values.where((log) => log.date == dateStr).toList();
  }

  @override
  Map<String, dynamic> getStatsForRange(DateTime start, DateTime end) {
    final logs = _logsBox.values.where((log) {
      final logDate = DateTime.parse(log.date);
      return logDate.isAfter(start.subtract(const Duration(days: 1))) &&
          logDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    final total = logs.length;
    final completed = logs.where((l) => l.completed).length;

    return {
      'total': total,
      'completed': completed,
      'rate': total > 0 ? (completed / total * 100).round() : 0,
    };
  }

  @override
  int calculateStreak(String habitId) {
    final logs = getLogForHabit(habitId);
    if (logs.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dateStr = _formatDate(checkDate);

      final log = logs.firstWhere(
        (l) => l.date == dateStr,
        orElse: () => HabitLogModel(
          id: "",
          habitId: "",
          date: "",
          createdAt: DateTime.now(),
          completed: false,
        ),
      );

      if (log.completed) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return streak;
  }

  @override
  Future<void> clearAll() async {
    await _habitsBox.clear();
    await _logsBox.clear();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
