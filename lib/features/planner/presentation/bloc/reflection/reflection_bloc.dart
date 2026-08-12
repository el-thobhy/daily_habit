import 'package:daily_habit/core/di/injection_container.dart';
import 'package:daily_habit/features/planner/domain/usecases/planner_usecases.dart';
import 'package:daily_habit/features/planner/presentation/bloc/reflection/reflection_event.dart';
import 'package:daily_habit/features/planner/presentation/bloc/reflection/reflection_state.dart';
import 'package:daily_habit/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReflectionBloc extends Bloc<ReflectionEvent, ReflectionState> {
  final GetReflectionForDate getReflectionForDate;
  final SaveReflection saveReflection;

  ReflectionBloc({
    required this.getReflectionForDate,
    required this.saveReflection,
  }) : super(ReflectionInitial()) {
    on<LoadReflectionForDate>(_onLoadReflection);
    on<SaveReflectionEvent>(_onSaveReflection);
  }

  Future<void> _onLoadReflection(LoadReflectionForDate event, Emitter<ReflectionState> emit) async {
    emit(ReflectionLoading());
    try {
      final reflection = await getReflectionForDate(event.date);
      emit(ReflectionLoaded(date: event.date, reflection: reflection));
    } catch (e) {
      emit(ReflectionError(e.toString()));
    }
  }

  Future<void> _onSaveReflection(SaveReflectionEvent event, Emitter<ReflectionState> emit) async {
    try {
      await saveReflection(event.reflection);
      emit(ReflectionSaved(event.reflection));
      add(LoadReflectionForDate(event.reflection.date));
      sl<SyncCubit>().sync();
    } catch (e) {
      emit(ReflectionError(e.toString()));
    }
  }
}
