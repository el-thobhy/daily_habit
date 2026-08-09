import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';
import 'package:daily_habit/features/planner/domain/entities/planner_task_entity.dart';

abstract class PlannerRepository {
  Future<List<PlannerTaskEntity>> getTasksForDate(DateTime date);
  Future<void> addTask(PlannerTaskEntity task);
  Future<void> updateTask(PlannerTaskEntity task);
  Future<void> deleteTask(String taskId);
  
  Future<DailyReflectionEntity?> getReflectionForDate(DateTime date);
  Future<void> saveReflection(DailyReflectionEntity reflection);
}
