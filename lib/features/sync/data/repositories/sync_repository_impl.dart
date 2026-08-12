import 'package:daily_habit/core/services/secure_storage_service.dart';
import 'package:daily_habit/features/habit/data/datasources/habit_local_datasource.dart';
import 'package:daily_habit/features/planner/data/datasources/planner_local_datasource.dart';
import 'package:daily_habit/features/sync/data/datasources/sync_remote_datasource.dart';

abstract class SyncRepository {
  Future<bool> executeSync();
}

class SyncRepositoryImpl implements SyncRepository {
  final SyncRemoteDataSource remoteDataSource;
  final HabitLocalDataSource habitLocalDataSource;
  final PlannerLocalDataSource plannerLocalDataSource;
  final SecureStorageService secureStorage;

  SyncRepositoryImpl({
    required this.remoteDataSource,
    required this.habitLocalDataSource,
    required this.plannerLocalDataSource,
    required this.secureStorage,
  });

  @override
  Future<bool> executeSync() async {
    try {
      final token = await secureStorage.getToken();
      if (token == null || token.isEmpty) return false;

      final lastSyncedAt = await secureStorage.getCustomKey('last_synced_at');

      final habits = await habitLocalDataSource.getUnsyncedHabitsJson();
      final logs = await habitLocalDataSource.getUnsyncedLogsJson();
      final tasks = await plannerLocalDataSource.getUnsyncedTasksJson();
      final reflections = await plannerLocalDataSource.getUnsyncedReflectionsJson();

      final payload = {
        'last_synced_at': lastSyncedAt,
        'habits': habits,
        'habit_logs': logs,
        'planner_tasks': tasks,
        'daily_reflections': reflections,
      };

      final response = await remoteDataSource.postSyncPayload(payload);

      if (response['status'] == 'success') {
        final serverChanges = response['server_changes'];
        final syncedAt = response['synced_at'];

        if (serverChanges != null) {
          if (serverChanges['habits'] != null) {
            await habitLocalDataSource.upsertHabitsFromSync(serverChanges['habits']);
          }
          if (serverChanges['habit_logs'] != null) {
            await habitLocalDataSource.upsertLogsFromSync(serverChanges['habit_logs']);
          }
          if (serverChanges['planner_tasks'] != null) {
            await plannerLocalDataSource.upsertTasksFromSync(serverChanges['planner_tasks']);
          }
          if (serverChanges['daily_reflections'] != null) {
            await plannerLocalDataSource.upsertReflectionsFromSync(serverChanges['daily_reflections']);
          }
        }

        if (syncedAt != null) {
          await secureStorage.saveCustomKey('last_synced_at', syncedAt.toString());
        }

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
