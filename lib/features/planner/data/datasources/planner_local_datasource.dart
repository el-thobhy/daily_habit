import 'package:daily_habit/core/services/secure_storage_service.dart';
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
  Future<String?> getCurrentUserId();
}

class PlannerLocalDataSourceImpl implements PlannerLocalDataSource {
  static const String tasksBoxName = 'planner_tasks_box';
  static const String reflectionsBoxName = 'daily_reflections_box';

  final SecureStorageService? secureStorage;
  late Box<Map> _tasksBox;
  late Box<Map> _reflectionsBox;
  String? _cachedUserId;

  PlannerLocalDataSourceImpl({this.secureStorage});

  @override
  Future<void> init() async {
    _tasksBox = await Hive.openBox<Map>(tasksBoxName);
    _reflectionsBox = await Hive.openBox<Map>(reflectionsBoxName);
    await getCurrentUserId();
  }

  @override
  Future<List<PlannerTaskModel>> getTasksForDate(String dateIso) async {
    final tasks = <PlannerTaskModel>[];
    final userId = await getCurrentUserId();
    for (var key in _tasksBox.keys) {
      final data = _tasksBox.get(key);
      if (data != null) {
        final model = PlannerTaskModel.fromMap(data);
        if (model.dateIso == dateIso &&
            (model.userId == userId || model.userId.isEmpty)) {
          tasks.add(model);
        }
      }
    }
    return tasks;
  }

  @override
  Future<void> saveTask(PlannerTaskModel task) async {
    var modelToSave = task;
    if (modelToSave.userId.isEmpty) {
      final currentUserId = await getCurrentUserId() ?? '';
      modelToSave = PlannerTaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        dateIso: task.dateIso,
        timeString: task.timeString,
        isCompleted: task.isCompleted,
        category: task.category,
        userId: currentUserId,
      );
    }
    await _tasksBox.put(modelToSave.id, modelToSave.toMap());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  @override
  Future<DailyReflectionModel?> getReflectionForDate(String dateIso) async {
    final userId = await getCurrentUserId();
    for (var key in _reflectionsBox.keys) {
      final data = _reflectionsBox.get(key);
      if (data != null) {
        final model = DailyReflectionModel.fromMap(data);
        if (model.dateIso == dateIso &&
            (model.userId == userId || model.userId.isEmpty)) {
          return model;
        }
      }
    }
    return null;
  }

  @override
  Future<void> saveReflection(DailyReflectionModel reflection) async {
    var modelToSave = reflection;
    if (modelToSave.userId.isEmpty) {
      final currentUserId = await getCurrentUserId() ?? '';
      modelToSave = DailyReflectionModel(
        id: reflection.id,
        dateIso: reflection.dateIso,
        todayLesson: reflection.todayLesson,
        memorableNotes: reflection.memorableNotes,
        moodRating: reflection.moodRating,
        userId: currentUserId,
      );
    }
    await _reflectionsBox.put(modelToSave.id, modelToSave.toMap());
  }

  @override
  Future<String?> getCurrentUserId() async {
    if (secureStorage != null) {
      final userData = await secureStorage!.getUserData();
      final id = userData['id'];
      if (id != null && id.isNotEmpty) {
        _cachedUserId = id;
        return id;
      } else {
        _cachedUserId = null;
        return null;
      }
    }
    return _cachedUserId;
  }
}
