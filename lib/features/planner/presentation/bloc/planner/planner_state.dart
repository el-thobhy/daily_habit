import 'package:daily_habit/features/planner/domain/entities/planner_task_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PlannerState extends Equatable {
  const PlannerState();
  @override
  List<Object?> get props => [];
}

class PlannerInitial extends PlannerState {}
class PlannerLoading extends PlannerState {}
class PlannerLoaded extends PlannerState {
  final DateTime selectedDate;
  final List<PlannerTaskEntity> tasks;

  const PlannerLoaded({
    required this.selectedDate,
    required this.tasks,
  });

  @override
  List<Object?> get props => [selectedDate, tasks];
}

class PlannerError extends PlannerState {
  final String message;
  const PlannerError(this.message);

  @override
  List<Object?> get props => [message];
}
