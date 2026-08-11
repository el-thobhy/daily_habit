import 'package:daily_habit/core/services/notification_service.dart';
import 'package:daily_habit/features/planner/domain/usecases/planner_usecases.dart';
import 'package:daily_habit/features/planner/presentation/bloc/planner/planner_event.dart';
import 'package:daily_habit/features/planner/presentation/bloc/planner/planner_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final GetTasksForDate getTasksForDate;
  final AddPlannerTask addPlannerTask;
  final UpdatePlannerTask updatePlannerTask;
  final DeletePlannerTask deletePlannerTask;
  final NotificationService notificationService;

  PlannerBloc({
    required this.getTasksForDate,
    required this.addPlannerTask,
    required this.updatePlannerTask,
    required this.deletePlannerTask,
    required this.notificationService,
  }) : super(PlannerInitial()) {
    on<LoadPlannerTasksForDate>(_onLoadTasks);
    on<AddPlannerTaskEvent>(_onAddTask);
    on<TogglePlannerTaskEvent>(_onToggleTask);
    on<DeletePlannerTaskEvent>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(
    LoadPlannerTasksForDate event,
    Emitter<PlannerState> emit,
  ) async {
    emit(PlannerLoading());
    try {
      final tasks = await getTasksForDate(event.date);
      emit(PlannerLoaded(selectedDate: event.date, tasks: tasks));
    } catch (e) {
      emit(PlannerError(e.toString()));
    }
  }

  Future<void> _onAddTask(
    AddPlannerTaskEvent event,
    Emitter<PlannerState> emit,
  ) async {
    try {
      await addPlannerTask(event.task);

      if (event.task.timeString != null && event.task.timeString!.isNotEmpty) {
        await notificationService.scheduleTaskNotification(
          taskId: event.task.id,
          title: event.task.title,
          description: event.task.description,
          date: event.task.date,
          timeString: event.task.timeString!,
        );
      }

      add(LoadPlannerTasksForDate(event.task.date));
    } catch (e) {
      emit(PlannerError(e.toString()));
    }
  }

  Future<void> _onToggleTask(
    TogglePlannerTaskEvent event,
    Emitter<PlannerState> emit,
  ) async {
    try {
      final updated = event.task.copyWith(isCompleted: !event.task.isCompleted);
      await updatePlannerTask(updated);

      if (updated.isCompleted) {
        await notificationService.cancelTaskNotification(updated.id);
      } else if (updated.timeString != null && updated.timeString!.isNotEmpty) {
        await notificationService.scheduleTaskNotification(
          taskId: updated.id,
          title: updated.title,
          description: updated.description,
          date: updated.date,
          timeString: updated.timeString!,
        );
      }

      add(LoadPlannerTasksForDate(event.task.date));
    } catch (e) {
      emit(PlannerError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
    DeletePlannerTaskEvent event,
    Emitter<PlannerState> emit,
  ) async {
    try {
      await deletePlannerTask(event.taskId);

      // Cancel the notification if it was scheduled
      notificationService.cancelTaskNotification(event.taskId);

      add(LoadPlannerTasksForDate(event.currentDate));
    } catch (e) {
      emit(PlannerError(e.toString()));
    }
  }
}
