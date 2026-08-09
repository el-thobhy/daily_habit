import 'package:daily_habit/features/planner/data/datasources/planner_local_datasource.dart';
import 'package:daily_habit/features/planner/data/models/daily_reflection_model.dart';
import 'package:daily_habit/features/planner/data/models/planner_task_model.dart';
import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';
import 'package:daily_habit/features/planner/domain/entities/planner_task_entity.dart';
import 'package:daily_habit/features/planner/domain/repositories/planner_repository.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerLocalDataSource localDataSource;

  PlannerRepositoryImpl({required this.localDataSource});

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Future<List<PlannerTaskEntity>> getTasksForDate(DateTime date) async {
    final models = await localDataSource.getTasksForDate(_formatDate(date));
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addTask(PlannerTaskEntity task) async {
    final model = PlannerTaskModel.fromEntity(task);
    await localDataSource.saveTask(model);
  }

  @override
  Future<void> updateTask(PlannerTaskEntity task) async {
    final model = PlannerTaskModel.fromEntity(task);
    await localDataSource.saveTask(model);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await localDataSource.deleteTask(taskId);
  }

  @override
  Future<DailyReflectionEntity?> getReflectionForDate(DateTime date) async {
    final model = await localDataSource.getReflectionForDate(_formatDate(date));
    return model?.toEntity();
  }

  @override
  Future<void> saveReflection(DailyReflectionEntity reflection) async {
    final model = DailyReflectionModel.fromEntity(reflection);
    await localDataSource.saveReflection(model);
  }
}
