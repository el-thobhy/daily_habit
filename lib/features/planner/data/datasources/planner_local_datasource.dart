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
  Future<List<Map<String, dynamic>>> getUnsyncedTasksJson();
  Future<List<Map<String, dynamic>>> getUnsyncedReflectionsJson();
  Future<void> upsertTasksFromSync(List<dynamic> tasksJson);
  Future<void> upsertReflectionsFromSync(List<dynamic> reflectionsJson);
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
            (model.userId == userId || model.userId.isEmpty) &&
            !model.isDeleted) {
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
        isDeleted: task.isDeleted,
        category: task.category,
        userId: currentUserId,
      );
    }
    await _tasksBox.put(modelToSave.id, modelToSave.toMap());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final data = _tasksBox.get(taskId);
    if (data != null) {
      final model = PlannerTaskModel.fromMap(data);
      final deletedModel = PlannerTaskModel(
        id: model.id,
        title: model.title,
        description: model.description,
        dateIso: model.dateIso,
        timeString: model.timeString,
        isCompleted: model.isCompleted,
        isDeleted: true,
        category: model.category,
        userId: model.userId,
      );
      await _tasksBox.put(taskId, deletedModel.toMap());
    } else {
      await _tasksBox.delete(taskId);
    }
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

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedTasksJson() async {
    final userId = await getCurrentUserId();
    if (userId == null || userId.isEmpty) return [];

    final tasks = <Map<String, dynamic>>[];
    for (var key in _tasksBox.keys) {
      final data = _tasksBox.get(key);
      if (data != null) {
        final model = PlannerTaskModel.fromMap(data);
        if (model.userId == userId) {
          final dateParts = model.dateIso.split('-');
          final dateTime = dateParts.length == 3
              ? DateTime.utc(
                  int.parse(dateParts[0]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[2]),
                )
              : DateTime.now().toUtc();

          tasks.add({
            'id': model.id,
            'user_id': model.userId,
            'title': model.title,
            'description': model.description,
            'date': dateTime.toIso8601String(),
            'time_string': model.timeString,
            'category': model.category,
            'is_completed': model.isCompleted,
            'is_deleted': model.isDeleted,
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }
    }
    return tasks;
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedReflectionsJson() async {
    final userId = await getCurrentUserId();
    if (userId == null || userId.isEmpty) return [];

    final reflections = <Map<String, dynamic>>[];
    for (var key in _reflectionsBox.keys) {
      final data = _reflectionsBox.get(key);
      if (data != null) {
        final model = DailyReflectionModel.fromMap(data);
        if (model.userId == userId) {
          final dateParts = model.dateIso.split('-');
          final dateTime = dateParts.length == 3
              ? DateTime.utc(
                  int.parse(dateParts[0]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[2]),
                )
              : DateTime.now().toUtc();

          reflections.add({
            'id': model.id,
            'user_id': model.userId,
            'date': dateTime.toIso8601String(),
            'mood': '${model.moodRating}',
            'reflection': model.memorableNotes,
            'lessons_learned': model.todayLesson,
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }
    }
    return reflections;
  }

  @override
  Future<void> upsertTasksFromSync(List<dynamic> tasksJson) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    // Purge locally marked deleted tasks after successful sync push
    final localKeysToRemove = <dynamic>[];
    for (var key in _tasksBox.keys) {
      final data = _tasksBox.get(key);
      if (data != null) {
        final model = PlannerTaskModel.fromMap(data);
        if (model.isDeleted) {
          localKeysToRemove.add(key);
        }
      }
    }
    for (var key in localKeysToRemove) {
      await _tasksBox.delete(key);
    }

    for (var item in tasksJson) {
      if (item['is_deleted'] == true) {
        await _tasksBox.delete(item['id']);
        continue;
      }

      final dateStr = item['date'] != null
          ? item['date'].toString().split('T').first
          : DateTime.now().toIso8601String().split('T').first;

      final model = PlannerTaskModel(
        id: item['id'],
        title: item['title'],
        description: item['description'] ?? '',
        dateIso: dateStr,
        timeString: item['time_string'] ?? '',
        isCompleted: item['is_completed'] ?? false,
        isDeleted: false,
        category: item['category'] ?? 'General',
        userId: userId,
      );
      await _tasksBox.put(model.id, model.toMap());
    }
  }

  @override
  Future<void> upsertReflectionsFromSync(List<dynamic> reflectionsJson) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    for (var item in reflectionsJson) {
      final dateStr = item['date'] != null
          ? item['date'].toString().split('T').first
          : DateTime.now().toIso8601String().split('T').first;

      final moodInt = int.tryParse(item['mood'] ?? '5') ?? 5;

      final model = DailyReflectionModel(
        id: item['id'],
        dateIso: dateStr,
        todayLesson: item['lessons_learned'] ?? '',
        memorableNotes: item['reflection'] ?? '',
        moodRating: moodInt,
        userId: userId,
      );
      await _reflectionsBox.put(model.id, model.toMap());
    }
  }
}
