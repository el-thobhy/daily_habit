import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_log_entity.dart';
import 'package:equatable/equatable.dart';

abstract class HabitListState extends Equatable {
  const HabitListState();

  @override
  List<Object?> get props => [];
}

class HabitListInitial extends HabitListState {}

class HabitListLoading extends HabitListState {}

class HabitListLoaded extends HabitListState {
  final List<HabitEntity> habits;
  final Map<String, HabitLogEntity?> todayLogs;
  final Map<String, int> streaks;
  final List<double> weeklyCompletionData;
  final String? celebrationMessage;
  final DateTime? selectedDate;

  const HabitListLoaded({
    required this.habits,
    required this.todayLogs,
    required this.streaks,
    required this.weeklyCompletionData,
    this.celebrationMessage,
    this.selectedDate,
  });

  HabitListLoaded copyWith({
    List<HabitEntity>? habits,
    Map<String, HabitLogEntity?>? todayLogs,
    Map<String, int>? streaks,
    List<double>? weeklyCompletionData,
    String? celebrationMessage,
    DateTime? selectedDate,
  }) {
    return HabitListLoaded(
      habits: habits ?? this.habits,
      todayLogs: todayLogs ?? this.todayLogs,
      streaks: streaks ?? this.streaks,
      weeklyCompletionData: weeklyCompletionData ?? this.weeklyCompletionData,
      celebrationMessage: celebrationMessage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [
        habits,
        todayLogs,
        streaks,
        weeklyCompletionData,
        celebrationMessage,
        selectedDate,
      ];
}

class HabitListError extends HabitListState {
  final String message;

  const HabitListError(this.message);

  @override
  List<Object?> get props => [message];
}
