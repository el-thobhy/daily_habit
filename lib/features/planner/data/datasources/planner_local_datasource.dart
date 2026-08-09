import 'package:daily_habit/features/planner/data/models/daily_reflection_model.dart';
import 'package:daily_habit/features/planner/data/models/planner_task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class PlannerLocalDataSource {
  Future<void> init();
  Future<List<PlannerTaskModel>> getTasksForDate(String dateIso);
  Future<void> saveTask(PlannerTaskModel task);
  Future<void> deleteTask(String taskId);
  
  Future<DailyReflectionModel?> getReflectionForDate(String dateIso);
  Future<void> saveReflection(DailyReflectionModel reflection);
}

class PlannerLocalDataSourceImpl implements PlannerLocalDataSource {
  static const String tasksBoxName = 'planner_tasks_box';
  static const String reflectionsBoxName = 'daily_reflections_box';

  late Box<Map> _tasksBox;
  late Box<Map> _reflectionsBox;

  @override
  Future<void> init() async {
    _tasksBox = await Hive.openBox<Map>(tasksBoxName);
    _reflectionsBox = await Hive.openBox<Map>(reflectionsBoxName);
  }

  @override
  Future<List<PlannerTaskModel>> getTasksForDate(String dateIso) async {
    final tasks = <PlannerTaskModel>[];
    for (var key in _tasksBox.keys) {
      final data = _tasksBox.get(key);
      if (data != null) {
        final model = PlannerTaskModel.fromMap(data);
        if (model.dateIso == dateIso) {
          tasks.add(model);
        }
      }
    }
    return tasks;
  }

  @override
  Future<void> saveTask(PlannerTaskModel task) async {
    await _tasksBox.put(task.id, task.toMap());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  @override
  Future<DailyReflectionModel?> getReflectionForDate(String dateIso) async {
    for (var key in _reflectionsBox.keys) {
      final data = _reflectionsBox.get(key);
      if (data != null) {
        final model = DailyReflectionModel.fromMap(data);
        if (model.dateIso == dateIso) {
          return model;
        }
      }
    }
    return null;
  }

  @override
  Future<void> saveReflection(DailyReflectionModel reflection) async {
    await _reflectionsBox.put(reflection.id, reflection.toMap());
  }
}
