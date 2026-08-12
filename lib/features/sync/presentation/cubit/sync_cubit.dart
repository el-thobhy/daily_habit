import 'package:daily_habit/features/sync/domain/usecases/perform_sync_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncingState extends SyncState {}

class SyncSuccessState extends SyncState {
  final DateTime timestamp;
  SyncSuccessState(this.timestamp);
}

class SyncErrorState extends SyncState {
  final String message;
  SyncErrorState(this.message);
}

class SyncCubit extends Cubit<SyncState> {
  final PerformSyncUseCase performSyncUseCase;

  SyncCubit({required this.performSyncUseCase}) : super(SyncInitial());

  Future<bool> sync() async {
    emit(SyncingState());
    final startTime = DateTime.now();
    final success = await performSyncUseCase();
    
    // Ensure SyncingState is visible for at least 600ms for smooth UI UX
    final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsedMs < 600) {
      await Future.delayed(Duration(milliseconds: 600 - elapsedMs));
    }

    if (success) {
      emit(SyncSuccessState(DateTime.now()));
    } else {
      emit(SyncErrorState("Sync Gagal. Menggunakan Data Lokal."));
    }
    return success;
  }
}
