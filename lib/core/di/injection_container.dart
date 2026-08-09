import 'package:daily_habit/core/services/notification_service.dart';
import 'package:daily_habit/features/habit/data/datasources/habit_local_datasource.dart';
import 'package:daily_habit/features/habit/data/repositories/habit_repository_impl.dart';
import 'package:daily_habit/features/habit/domain/repositories/habit_repository.dart';
import 'package:daily_habit/features/habit/domain/usecases/habit_usecases.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_bloc.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_stats/habit_stats_bloc.dart';
import 'package:daily_habit/features/planner/data/datasources/planner_local_datasource.dart';
import 'package:daily_habit/features/planner/data/repositories/planner_repository_impl.dart';
import 'package:daily_habit/features/planner/domain/repositories/planner_repository.dart';
import 'package:daily_habit/features/planner/domain/usecases/planner_usecases.dart';
import 'package:daily_habit/features/planner/presentation/bloc/planner/planner_bloc.dart';
import 'package:daily_habit/features/planner/presentation/bloc/reflection/reflection_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Services
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerSingleton<NotificationService>(notificationService);

  // Data sources
  final localDataSource = HabitLocalDataSourceImpl();
  await localDataSource.init();
  sl.registerSingleton<HabitLocalDataSource>(localDataSource);

  final plannerLocalDataSource = PlannerLocalDataSourceImpl();
  await plannerLocalDataSource.init();
  sl.registerSingleton<PlannerLocalDataSource>(plannerLocalDataSource);

  // Repositories
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<PlannerRepository>(
    () => PlannerRepositoryImpl(localDataSource: sl()),
  );

  // Use cases (Habit)
  sl.registerLazySingleton(() => GetHabitsForToday(sl()));
  sl.registerLazySingleton(() => GetAllHabits(sl()));
  sl.registerLazySingleton(() => CreateHabit(sl()));
  sl.registerLazySingleton(() => UpdateHabit(sl()));
  sl.registerLazySingleton(() => ArchiveHabit(sl()));
  sl.registerLazySingleton(() => UnarchiveHabit(sl()));
  sl.registerLazySingleton(() => LogHabit(sl()));
  sl.registerLazySingleton(() => CalculateStreak(sl()));

  // Use cases (Planner & Reflection)
  sl.registerLazySingleton(() => GetTasksForDate(sl()));
  sl.registerLazySingleton(() => AddPlannerTask(sl()));
  sl.registerLazySingleton(() => UpdatePlannerTask(sl()));
  sl.registerLazySingleton(() => DeletePlannerTask(sl()));
  sl.registerLazySingleton(() => GetReflectionForDate(sl()));
  sl.registerLazySingleton(() => SaveReflection(sl()));

  // BLoCs
  sl.registerFactory(
    () => HabitListBloc(
      getHabitsForToday: sl(),
      createHabit: sl(),
      updateHabit: sl(),
      archiveHabit: sl(),
      unarchiveHabit: sl(),
      logHabit: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => HabitStatsBloc(
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => PlannerBloc(
      getTasksForDate: sl(),
      addPlannerTask: sl(),
      updatePlannerTask: sl(),
      deletePlannerTask: sl(),
    ),
  );

  sl.registerFactory(
    () => ReflectionBloc(
      getReflectionForDate: sl(),
      saveReflection: sl(),
    ),
  );
}
