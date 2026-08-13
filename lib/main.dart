import 'package:daily_habit/core/di/injection_container.dart';
import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:daily_habit/features/auth/presentation/views/splash_screen.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_bloc.dart';
import 'package:daily_habit/features/planner/presentation/bloc/planner/planner_bloc.dart';
import 'package:daily_habit/features/planner/presentation/bloc/reflection/reflection_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await MobileAds.instance.initialize(); // Inisialisasi Admob
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await initDI();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<HabitListBloc>(create: (_) => sl<HabitListBloc>()),
        BlocProvider<PlannerBloc>(create: (_) => sl<PlannerBloc>()),
        BlocProvider<ReflectionBloc>(create: (_) => sl<ReflectionBloc>()),
      ],
      child: MaterialApp(
        title: 'Daily Planner',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: FlutterQuillLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppTheme.background,
          textTheme: AppTheme.textTheme,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primary,
            brightness: Brightness.light,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
