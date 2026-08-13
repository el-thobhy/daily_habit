import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:daily_habit/features/auth/presentation/bloc/auth_event.dart';
import 'package:daily_habit/features/auth/presentation/bloc/auth_state.dart';
import 'package:daily_habit/features/habit/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:daily_habit/features/landing/presentation/pages/landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else if (state is Unauthenticated || state is AuthError) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LandingPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Daily Planner',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track Habits • Plan Days • Learn Everyday',
                style: AppTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
