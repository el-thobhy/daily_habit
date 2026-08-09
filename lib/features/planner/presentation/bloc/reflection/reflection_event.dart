import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ReflectionEvent extends Equatable {
  const ReflectionEvent();
  @override
  List<Object?> get props => [];
}

class LoadReflectionForDate extends ReflectionEvent {
  final DateTime date;
  const LoadReflectionForDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SaveReflectionEvent extends ReflectionEvent {
  final DailyReflectionEntity reflection;
  const SaveReflectionEvent(this.reflection);

  @override
  List<Object?> get props => [reflection];
}
