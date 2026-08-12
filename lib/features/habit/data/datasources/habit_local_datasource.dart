import 'package:daily_habit/core/services/secure_storage_service.dart';
import 'package:daily_habit/data_model/habit_data_model.dart';
import 'package:daily_habit/data_model/habit_log_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class HabitLocalDataSource {
  Future<void> init();
  Future<void> createHabit(HabitDataModel habit);
  List<HabitDataModel> getAllHabits({
    bool includeArchived = false,
    String? userId,
  });
  List<HabitDataModel> getHabitsForToday({String? userId, DateTime? date});
  Future<void> updateHabit(HabitDataModel habit);
  Future<void> archiveHabit(String id);
  Future<void> unarchiveHabit(String id);
  Future<void> logHabit({
    required String habitId,
    required bool completed,
    int countValue = 1,
    String? note,
    DateTime? date,
  });
  HabitLogModel? getLogForDate(String habitId, DateTime date);
  List<HabitLogModel> getLogForHabit(String habitId, {int? limit});
  List<HabitLogModel?> getLogsForDate(DateTime date);
  Map<String, dynamic> getStatsForRange(DateTime start, DateTime end);
  int calculateStreak(String habitId);
  Future<void> clearAll();
  Future<String?> getCurrentUserId();
  Future<List<Map<String, dynamic>>> getUnsyncedHabitsJson();
  Future<List<Map<String, dynamic>>> getUnsyncedLogsJson();
  Future<void> upsertHabitsFromSync(List<dynamic> habitsJson);
  Future<void> upsertLogsFromSync(List<dynamic> logsJson);
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  static const String habitsBoxName = 'habits';
  static const String logsBoxName = 'habit_logs';

  final SecureStorageService? secureStorage;
  late Box<HabitDataModel> _habitsBox;
  late Box<HabitLogModel> _logsBox;
  String? _cachedUserId;

  HabitLocalDataSourceImpl({this.secureStorage});

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
    await getCurrentUserId();
  }

  @override
  Future<String?> getCurrentUserId() async {
    if (secureStorage != null) {
      final userData = await secureStorage!.getUserData();
      final id = userData['id'];
      if (id != null && id.isNotEmpty) {
        _cachedUserId = id;
        return id;
      } else {
        _cachedUserId = null;
        return null;
      }
    }
    return _cachedUserId;
  }

  @override
  Future<void> createHabit(HabitDataModel habit) async {
    if (habit.userId == null || habit.userId!.isEmpty) {
      habit.userId = await getCurrentUserId();
    }
    await _habitsBox.put(habit.id, habit);
  }

  @override
  List<HabitDataModel> getAllHabits({
    bool includeArchived = false,
    String? userId,
  }) {
    final targetUserId = userId ?? _cachedUserId;
    var habits = _habitsBox.values.toList();

    if (targetUserId != null && targetUserId.isNotEmpty) {
      habits = habits
          .where((h) => h.userId == null || h.userId == targetUserId)
          .toList();
    }

    habits.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (!includeArchived) {
      return habits.where((h) => !h.isArchived).toList();
    }
    return habits;
  }

  @override
  List<HabitDataModel> getHabitsForToday({String? userId, DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final weekday = targetDate.weekday;
    return getAllHabits(
      userId: userId,
    ).where((h) => h.frequency.contains(weekday)).toList();
  }

  @override
  Future<void> updateHabit(HabitDataModel habit) async {
    habit.updatedAt = DateTime.now();
    if (habit.userId == null || habit.userId!.isEmpty) {
      habit.userId = await getCurrentUserId();
    }
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
    DateTime? date,
  }) async {
    final userId = await getCurrentUserId();
    final logDate = _formatDate(date ?? DateTime.now());
    final existingLog = _logsBox.values.firstWhere(
      (log) =>
          log.habitId == habitId &&
          log.date == logDate &&
          (log.userId == null || log.userId == userId),
      orElse: () => HabitLogModel(
        id: '${habitId}_$logDate',
        habitId: habitId,
        date: logDate,
        createdAt: DateTime.now(),
        userId: userId,
      ),
    );

    existingLog
      ..completed = completed
      ..countValue = countValue
      ..note = note
      ..completedAt = completed ? DateTime.now() : null
      ..userId = userId;

    await _logsBox.put(existingLog.id, existingLog);
  }

  @override
  HabitLogModel? getLogForDate(String habitId, DateTime date) {
    final dateStr = _formatDate(date);
    try {
      return _logsBox.values.firstWhere(
        (log) =>
            log.habitId == habitId &&
            log.date == dateStr &&
            (log.userId == null || log.userId == _cachedUserId),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  List<HabitLogModel> getLogForHabit(String habitId, {int? limit}) {
    final logs =
        _logsBox.values
            .where(
              (log) =>
                  log.habitId == habitId &&
                  (log.userId == null || log.userId == _cachedUserId),
            )
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
    return _logsBox.values
        .where(
          (log) =>
              log.date == dateStr &&
              (log.userId == null || log.userId == _cachedUserId),
        )
        .toList();
  }

  @override
  Map<String, dynamic> getStatsForRange(DateTime start, DateTime end) {
    final logs = _logsBox.values.where((log) {
      final logDate = DateTime.parse(log.date);
      final isUserMatch = log.userId == null || log.userId == _cachedUserId;
      return isUserMatch &&
          logDate.isAfter(start.subtract(const Duration(days: 1))) &&
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

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedHabitsJson() async {
    final userId = await getCurrentUserId();
    if (userId == null || userId.isEmpty) return [];

    final habits = _habitsBox.values
        .where((h) => h.userId == userId)
        .map(
          (h) => {
            'id': h.id,
            'user_id': h.userId ?? userId,
            'title': h.name,
            'icon_name': h.emoji,
            'color_hex': '#${h.colorValue.toRadixString(16).padLeft(8, '0')}',
            'target_days': h.targetCount,
            'category': h.categoryId ?? 'General',
            'frequency_type': 'daily',
            'reminder_time': h.reminderTime,
            'is_archived': h.isArchived,
            'created_at': h.createdAt.toUtc().toIso8601String(),
            'updated_at': h.updatedAt.toUtc().toIso8601String(),
          },
        )
        .toList();

    return habits;
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedLogsJson() async {
    final userId = await getCurrentUserId();
    if (userId == null || userId.isEmpty) return [];
    final logs = _logsBox.values
        .where((l) => l.userId == userId)
        .map(
          (l) {
            final dateParts = l.date.split('-');
            final dateTime = dateParts.length == 3
                ? DateTime.utc(
                    int.parse(dateParts[0]),
                    int.parse(dateParts[1]),
                    int.parse(dateParts[2]),
                  )
                : DateTime.now().toUtc();
            return {
              'id': l.id,
              'user_id': l.userId ?? userId,
              'habit_id': l.habitId,
              'date': dateTime.toIso8601String(),
              'is_done': l.completed,
              'notes': l.note ?? '',
              'updated_at': (l.completedAt ?? l.createdAt).toUtc().toIso8601String(),
            };
          },
        )
        .toList();
    return logs;
  }

  @override
  Future<void> upsertHabitsFromSync(List<dynamic> habitsJson) async {
    final currentUserId = await getCurrentUserId();
    if (currentUserId == null) return;
    for (var item in habitsJson) {
      final colorHexStr = (item['color_hex'] as String? ?? '').replaceAll('#', '');
      final colorInt = int.tryParse(colorHexStr, radix: 16) ?? 4280391411;

      final model = HabitDataModel(
        id: item['id'],
        name: item['title'] ?? '',
        emoji: item['icon_name'] ?? '⭐',
        colorValue: colorInt,
        frequency: const [1, 2, 3, 4, 5, 6, 7],
        targetCount: item['target_days'] ?? 1,
        reminderTime: item['reminder_time'],
        isArchived: item['is_archived'] ?? false,
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['updated_at']),
        userId: currentUserId,
      );
      await _habitsBox.put(model.id, model);
    }
  }

  @override
  Future<void> upsertLogsFromSync(List<dynamic> logsJson) async {
    final currentUserId = await getCurrentUserId();
    if (currentUserId == null) return;
    for (var item in logsJson) {
      final dateStr = item['date'] != null
          ? item['date'].toString().split('T').first
          : _formatDate(DateTime.now());

      final model = HabitLogModel(
        id: item['id'],
        habitId: item['habit_id'],
        date: dateStr,
        completed: item['is_done'] ?? false,
        countValue: 1,
        note: item['notes'],
        completedAt: item['updated_at'] != null ? DateTime.parse(item['updated_at']) : null,
        createdAt: DateTime.parse(item['updated_at'] ?? DateTime.now().toIso8601String()),
        userId: currentUserId,
      );
      await _logsBox.put(model.id, model);
    }
  }
}
