import 'dart:core';

import 'package:daily_habit/data_model/habit_data_model.dart';
import 'package:daily_habit/data_model/habit_log_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  // Add this getter to HiveDatabase class

  static const String habitsBoxName = 'habits';
  static const String logsBoxName = 'habit_logs';

  late Box<HabitDataModel> _habitsBox;
  late Box<HabitLogModel> _logsBox;

  static final HiveDatabase _instance = HiveDatabase._internal();
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();
  
  Box<HabitDataModel> get habitsBox => _habitsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(HabitDataModelAdapter());
    Hive.registerAdapter(HabitLogModelAdapter());

    _habitsBox = await Hive.openBox<HabitDataModel>(habitsBoxName);
    _logsBox = await Hive.openBox<HabitLogModel>(logsBoxName);
  }

  // ====================== Habit CRUD ====================
  Future<void> createHabit(HabitDataModel habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  List<HabitDataModel> getAllHabits({bool includeArchived = false}){
    final habits = _habitsBox.values.toList()
      ..sort((a,b) => a.sortOrder.compareTo(b.sortOrder));

    if(!includeArchived){
      return habits.where((h) => !h.isArchived).toList();
    }
    return habits;
  }

  List<HabitDataModel> getHabitsForToday(){
    final today = DateTime.now().weekday;
    return getAllHabits()
      .where((h)=> h.frequency.contains(today))
      .toList();
  }

  Future<void> updateHabit(HabitDataModel habit) async {
    habit.updatedAt = DateTime.now();
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> archiveHabit(String id) async {
    final habit = _habitsBox.get(id);
    if(habit != null){
      habit.isArchived = true;
      await habit.save();
    }
  }

  // =============== LOGS CRUD ====================
  Future<void> logHabit({required String habitId, required bool completed, int countValue = 1, String? note}) async {
    final today = _formatDate(DateTime.now());
    final existingLog = _logsBox.values.firstWhere((log) => log.habitId == habitId && log.date == today, orElse: () => HabitLogModel(
        id: '${habitId}_$today',
        habitId: habitId,
        date: today,
        createdAt: DateTime.now(),
      )
    );

    existingLog
      ..completed = completed
      ..countValue = countValue
      ..note = note
      ..completedAt = completed ? DateTime.now() : null;

    await _logsBox.put(existingLog.id, existingLog);
  }

  HabitLogModel? getLogForDate(String habitId, DateTime date) {
    final dateStr = _formatDate(date);
    try{
      return _logsBox.values.firstWhere((log) => log.habitId == habitId && log.date == dateStr);
    }catch (e){
      return null;
    }
  }

  List<HabitLogModel> getLogForHabit(String habitId,{int? limit}) {
    final logs = _logsBox.values
      .where((log) => log.habitId == habitId)
      .toList()
      ..sort((a,b)=>b.date.compareTo(a.date));

    if(limit != null){
      return logs.take(limit).toList();
    }
    return logs;
  }

  //get completion rate for date range
  Map<String, dynamic> getStatsForRange(DateTime start, DateTime end) {
    final logs = _logsBox.values.where((log) {
      final logDate = DateTime.parse(log.date);
      return logDate.isAfter(start.subtract(const Duration(days: 1))) && logDate.isBefore(end.add(const Duration(days:1)));
    }).toList();

    final total = logs.length;
    final completed = logs.where((l) => l.completed).length;

    return {
      'total': total,
      'completed': completed,
      'rate': total > 0 ? (completed/total * 100).round() : 0,
    };
  }


  // =============== Streak Calculation ===========
  int calculateStreak(String habitId){
    final logs = getLogForHabit(habitId);
    if(logs.isEmpty) return 0;
    
    int streak = 0;
    final today = DateTime.now();

    for(int i = 0; i<365; i++){
      final checkDate = today.subtract(Duration(days: 1));
      final dateStr = _formatDate(checkDate);

      final log = logs.firstWhere(
        (l) => l.date == dateStr,
        orElse: () => HabitLogModel(
          id: "", 
          habitId: "", 
          date: "", 
          createdAt: DateTime.now(),
          completed: false)
      );

      if(log.completed){
        streak++;
      }else if(i>0){
        break;
      }
    }

    return streak;
  }

  // =============== Helpers ======================
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
  }

  Future<void> clearAll() async {
    await _habitsBox.clear();
    await _logsBox.clear();
  }
  // lib/data/services/hive_database.dart

  List<HabitLogModel?> getLogsForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return _logsBox.values.where((log) => log.date == dateStr).toList();
  }
}