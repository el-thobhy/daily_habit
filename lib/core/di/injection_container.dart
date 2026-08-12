import 'package:daily_habit/core/network/api_client.dart';
import 'package:daily_habit/core/services/notification_service.dart';
import 'package:daily_habit/core/services/secure_storage_service.dart';
import 'package:daily_habit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:daily_habit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:daily_habit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:daily_habit/features/auth/domain/repositories/auth_repository.dart';
import 'package:daily_habit/features/auth/domain/usecases/auth_usecases.dart';
import 'package:daily_habit/features/auth/presentation/bloc/auth_bloc.dart';
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

  final secureStorage = SecureStorageService();
  sl.registerSingleton<SecureStorageService>(secureStorage);

  final apiClient = ApiClient(secureStorage: sl());
  sl.registerSingleton<ApiClient>(apiClient);

  // Data sources
  final localDataSource = HabitLocalDataSourceImpl(secureStorage: sl());
  await localDataSource.init();
  sl.registerSingleton<HabitLocalDataSource>(localDataSource);

  final plannerLocalDataSource = PlannerLocalDataSourceImpl(secureStorage: sl());
  await plannerLocalDataSource.init();
  sl.registerSingleton<PlannerLocalDataSource>(plannerLocalDataSource);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  // Repositories
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<PlannerRepository>(
    () => PlannerRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      habitLocalDataSource: sl(),
      plannerLocalDataSource: sl(),
      notificationService: sl(),
    ),
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

  // Use cases (Auth)
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      verifyOtpUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

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

  sl.registerFactory(() => HabitStatsBloc(repository: sl()));

  sl.registerFactory(
    () => PlannerBloc(
      getTasksForDate: sl(),
      addPlannerTask: sl(),
      updatePlannerTask: sl(),
      deletePlannerTask: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerFactory(
    () => ReflectionBloc(getReflectionForDate: sl(), saveReflection: sl()),
  );
}
