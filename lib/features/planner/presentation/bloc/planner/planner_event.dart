import 'package:daily_habit/features/planner/domain/entities/planner_task_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PlannerEvent extends Equatable {
  const PlannerEvent();
  @override
  List<Object?> get props => [];
}

class LoadPlannerTasksForDate extends PlannerEvent {
  final DateTime date;
  const LoadPlannerTasksForDate(this.date);

  @override
  List<Object?> get props => [date];
}

class AddPlannerTaskEvent extends PlannerEvent {
  final PlannerTaskEntity task;
  const AddPlannerTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class TogglePlannerTaskEvent extends PlannerEvent {
  final PlannerTaskEntity task;
  const TogglePlannerTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeletePlannerTaskEvent extends PlannerEvent {
  final String taskId;
  final DateTime currentDate;
  const DeletePlannerTaskEvent({required this.taskId, required this.currentDate});

  @override
  List<Object?> get props => [taskId, currentDate];
}
