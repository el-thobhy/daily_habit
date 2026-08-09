import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_habit/core/usecase/usecase.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_log_entity.dart';
import 'package:daily_habit/features/habit/domain/repositories/habit_repository.dart';
import 'package:daily_habit/features/habit/domain/usecases/habit_usecases.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_event.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_state.dart';

class HabitListBloc extends Bloc<HabitListEvent, HabitListState> {
  final GetHabitsForToday getHabitsForToday;
  final CreateHabit createHabit;
  final UpdateHabit updateHabit;
  final ArchiveHabit archiveHabit;
  final UnarchiveHabit unarchiveHabit;
  final LogHabit logHabit;
  final HabitRepository repository;

  HabitListBloc({
    required this.getHabitsForToday,
    required this.createHabit,
    required this.updateHabit,
    required this.archiveHabit,
    required this.unarchiveHabit,
    required this.logHabit,
    required this.repository,
  }) : super(HabitListInitial()) {
    on<LoadTodayHabitsEvent>(_onLoadTodayHabits);
    on<ToggleHabitCompletionEvent>(_onToggleHabitCompletion);
    on<AddHabitEvent>(_onAddHabit);
    on<UpdateHabitEvent>(_onUpdateHabit);
    on<ArchiveHabitEvent>(_onArchiveHabit);
    on<UnarchiveHabitEvent>(_onUnarchiveHabit);
  }

  Future<void> _onLoadTodayHabits(
    LoadTodayHabitsEvent event,
    Emitter<HabitListState> emit,
  ) async {
    emit(HabitListLoading());
    try {
      final habits = await getHabitsForToday(NoParams());
      final today = DateTime.now();

      final todayLogs = <String, HabitLogEntity?>{};
      final streaks = <String, int>{};

      for (final habit in habits) {
        todayLogs[habit.id] = repository.getLogForDate(habit.id, today);
        streaks[habit.id] = repository.calculateStreak(habit.id);
      }

      final weeklyData = _getWeeklyCompletionData(habits);

      emit(HabitListLoaded(
        habits: habits,
        todayLogs: todayLogs,
        streaks: streaks,
        weeklyCompletionData: weeklyData,
      ));
    } catch (e) {
      emit(HabitListError(e.toString()));
    }
  }

  Future<void> _onToggleHabitCompletion(
    ToggleHabitCompletionEvent event,
    Emitter<HabitListState> emit,
  ) async {
    if (state is! HabitListLoaded) return;
    final currentState = state as HabitListLoaded;

    try {
      final habitId = event.habitId;
      final currentLog = currentState.todayLogs[habitId];
      final newCompleted = !(currentLog?.completed ?? false);

      await logHabit(LogHabitParams(
        habitId: habitId,
        completed: newCompleted,
        countValue: 1,
      ));

      final newStreak = repository.calculateStreak(habitId);
      final today = DateTime.now();

      final newLog = HabitLogEntity(
        id: '${habitId}_${_formatDate(today)}',
        habitId: habitId,
        date: _formatDate(today),
        completed: newCompleted,
        countValue: 1,
        completedAt: newCompleted ? DateTime.now() : null,
        createdAt: currentLog?.createdAt ?? DateTime.now(),
      );

      final updatedLogs = Map<String, HabitLogEntity?>.from(currentState.todayLogs);
      updatedLogs[habitId] = newLog;

      final updatedStreaks = Map<String, int>.from(currentState.streaks);
      updatedStreaks[habitId] = newStreak;

      final updatedWeeklyData = _getWeeklyCompletionData(currentState.habits);

      int? celebrationStreak;
      if (newCompleted && newStreak > 0 && newStreak % 7 == 0) {
        celebrationStreak = newStreak;
      }

      emit(currentState.copyWith(
        todayLogs: updatedLogs,
        streaks: updatedStreaks,
        weeklyCompletionData: updatedWeeklyData,
        celebrationMessage: celebrationStreak != null ? '$celebrationStreak Day Streak!' : null,
      ));
    } catch (e) {
      emit(HabitListError(e.toString()));
    }
  }

  Future<void> _onAddHabit(
    AddHabitEvent event,
    Emitter<HabitListState> emit,
  ) async {
    try {
      await createHabit(event.habit);
      add(LoadTodayHabitsEvent());
    } catch (e) {
      emit(HabitListError(e.toString()));
    }
  }

  Future<void> _onUpdateHabit(
    UpdateHabitEvent event,
    Emitter<HabitListState> emit,
  ) async {
    try {
      await updateHabit(event.habit);
      add(LoadTodayHabitsEvent());
    } catch (e) {
      emit(HabitListError(e.toString()));
    }
  }

  Future<void> _onArchiveHabit(
    ArchiveHabitEvent event,
    Emitter<HabitListState> emit,
  ) async {
    try {
      await archiveHabit(event.habitId);
      add(LoadTodayHabitsEvent());
    } catch (e) {
      emit(HabitListError(e.toString()));
    }
  }

  Future<void> _onUnarchiveHabit(
    UnarchiveHabitEvent event,
    Emitter<HabitListState> emit,
  ) async {
    try {
      await unarchiveHabit(event.habitId);
      add(LoadTodayHabitsEvent());
    } catch (e) {
      emit(HabitListError(e.toString()));
    }
  }

  List<double> _getWeeklyCompletionData(List<HabitEntity> habits) {
    final data = <double>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLogs = repository.getLogsForDate(date);
      final completed = dayLogs.where((log) => log?.completed == true).length;
      final total = habits.where((h) => h.frequency.contains(date.weekday)).length;

      data.add(total > 0 ? (completed / total) * 100 : 0);
    }
    return data;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
