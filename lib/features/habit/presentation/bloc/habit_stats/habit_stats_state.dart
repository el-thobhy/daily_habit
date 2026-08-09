import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:equatable/equatable.dart';

abstract class HabitStatsState extends Equatable {
  const HabitStatsState();

  @override
  List<Object?> get props => [];
}

class HabitStatsInitial extends HabitStatsState {}

class HabitStatsLoading extends HabitStatsState {}

class HabitStatsLoaded extends HabitStatsState {
  final List<HabitEntity> habits;
  final Map<String, int> streaks;
  final Map<String, List<double>> weeklyData;
  final int totalCurrentStreak;
  final double weeklyCompletionRate;
  final int bestStreak;
  final String bestStreakHabitName;

  const HabitStatsLoaded({
    required this.habits,
    required this.streaks,
    required this.weeklyData,
    required this.totalCurrentStreak,
    required this.weeklyCompletionRate,
    required this.bestStreak,
    required this.bestStreakHabitName,
  });

  @override
  List<Object?> get props => [
        habits,
        streaks,
        weeklyData,
        totalCurrentStreak,
        weeklyCompletionRate,
        bestStreak,
        bestStreakHabitName,
      ];
}

class HabitStatsError extends HabitStatsState {
  final String message;

  const HabitStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
