import 'package:equatable/equatable.dart';

abstract class HabitStatsEvent extends Equatable {
  const HabitStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabitStatsEvent extends HabitStatsEvent {}
