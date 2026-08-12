import 'package:daily_habit/features/sync/data/repositories/sync_repository_impl.dart';

class PerformSyncUseCase {
  final SyncRepository repository;

  PerformSyncUseCase(this.repository);

  Future<bool> call() async {
    return await repository.executeSync();
  }
}
