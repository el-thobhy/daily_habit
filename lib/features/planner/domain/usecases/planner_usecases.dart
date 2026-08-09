import 'package:daily_habit/core/usecase/usecase.dart';
import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';
import 'package:daily_habit/features/planner/domain/entities/planner_task_entity.dart';
import 'package:daily_habit/features/planner/domain/repositories/planner_repository.dart';

class GetTasksForDate implements UseCase<List<PlannerTaskEntity>, DateTime> {
  final PlannerRepository repository;
  GetTasksForDate(this.repository);

  @override
  Future<List<PlannerTaskEntity>> call(DateTime params) {
    return repository.getTasksForDate(params);
  }
}

class AddPlannerTask implements UseCase<void, PlannerTaskEntity> {
  final PlannerRepository repository;
  AddPlannerTask(this.repository);

  @override
  Future<void> call(PlannerTaskEntity params) {
    return repository.addTask(params);
  }
}

class UpdatePlannerTask implements UseCase<void, PlannerTaskEntity> {
  final PlannerRepository repository;
  UpdatePlannerTask(this.repository);

  @override
  Future<void> call(PlannerTaskEntity params) {
    return repository.updateTask(params);
  }
}

class DeletePlannerTask implements UseCase<void, String> {
  final PlannerRepository repository;
  DeletePlannerTask(this.repository);

  @override
  Future<void> call(String params) {
    return repository.deleteTask(params);
  }
}

class GetReflectionForDate implements UseCase<DailyReflectionEntity?, DateTime> {
  final PlannerRepository repository;
  GetReflectionForDate(this.repository);

  @override
  Future<DailyReflectionEntity?> call(DateTime params) {
    return repository.getReflectionForDate(params);
  }
}

class SaveReflection implements UseCase<void, DailyReflectionEntity> {
  final PlannerRepository repository;
  SaveReflection(this.repository);

  @override
  Future<void> call(DailyReflectionEntity params) {
    return repository.saveReflection(params);
  }
}
