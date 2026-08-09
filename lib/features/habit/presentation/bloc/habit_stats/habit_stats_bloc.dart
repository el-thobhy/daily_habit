import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_habit/features/habit/domain/repositories/habit_repository.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_stats/habit_stats_event.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_stats/habit_stats_state.dart';

class HabitStatsBloc extends Bloc<HabitStatsEvent, HabitStatsState> {
  final HabitRepository repository;

  HabitStatsBloc({required this.repository}) : super(HabitStatsInitial()) {
    on<LoadHabitStatsEvent>(_onLoadHabitStats);
  }

  Future<void> _onLoadHabitStats(
    LoadHabitStatsEvent event,
    Emitter<HabitStatsState> emit,
  ) async {
    emit(HabitStatsLoading());
    try {
      final habits = repository.getAllHabits();
      final now = DateTime.now();

      final streaks = <String, int>{};
      final weeklyData = <String, List<double>>{};

      int totalStreak = 0;
      int bestStreak = 0;
      String bestHabit = '';

      for (final habit in habits) {
        final streak = repository.calculateStreak(habit.id);
        streaks[habit.id] = streak;
        totalStreak += streak;

        if (streak > bestStreak) {
          bestStreak = streak;
          bestHabit = habit.name;
        }

        final weekData = <double>[];
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final log = repository.getLogForDate(habit.id, date);
          weekData.add(log?.completed == true ? 100.0 : 0.0);
        }
        weeklyData[habit.id] = weekData;
      }

      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStats = repository.getStatsForRange(weekStart, now);
      final completionRate = (weekStats['rate'] as int).toDouble();

      emit(HabitStatsLoaded(
        habits: habits,
        streaks: streaks,
        weeklyData: weeklyData,
        totalCurrentStreak: totalStreak,
        weeklyCompletionRate: completionRate,
        bestStreak: bestStreak,
        bestStreakHabitName: bestHabit,
      ));
    } catch (e) {
      emit(HabitStatsError(e.toString()));
    }
  }
}
