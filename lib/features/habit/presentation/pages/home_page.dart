import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/core/widgets/habit_card.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_bloc.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_event.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_state.dart';
import 'package:daily_habit/features/habit/presentation/pages/stats_page.dart';
import 'package:daily_habit/features/habit/presentation/widgets/add_habit_sheet.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    context.read<HabitListBloc>().add(LoadTodayHabitsEvent());
  }

  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitSheet(
        onSave: (data) {
          final habit = HabitEntity(
            id: _uuid.v4(),
            name: data['name'],
            emoji: data['emoji'],
            colorValue: data['colorValue'],
            frequency: data['frequency'],
            reminderTime: data['reminderTime'],
            targetCount: data['targetCount'] ?? 1,
            unit: data['unit'],
            categoryId: data['categoryId'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          context.read<HabitListBloc>().add(AddHabitEvent(habit));
        },
      ),
    );
  }

  void _showEditHabitSheet(HabitEntity habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitSheet(
        habit: habit,
        onSave: (data) {
          final updated = habit.copyWith(
            name: data['name'],
            emoji: data['emoji'],
            colorValue: data['colorValue'],
            frequency: data['frequency'],
            reminderTime: data['reminderTime'],
            targetCount: data['targetCount'] ?? 1,
            unit: data['unit'],
            categoryId: data['categoryId'],
            updatedAt: DateTime.now(),
          );
          context.read<HabitListBloc>().add(UpdateHabitEvent(updated));
        },
      ),
    );
  }

  void _showStreakCelebration(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            const Text('You\'re on fire! Keep it up!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  String _getMotivationalMessage(double progress) {
    if (progress == 0) return 'Let\'s get started!';
    if (progress < 0.5) return 'Off to a good start!';
    if (progress < 1.0) return 'More than halfway there!';
    return 'All habits completed today! 🎉';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocConsumer<HabitListBloc, HabitListState>(
          listener: (context, state) {
            if (state is HabitListLoaded && state.celebrationMessage != null) {
              _showStreakCelebration(state.celebrationMessage!);
            }
          },
          builder: (context, state) {
            if (state is HabitListLoading || state is HabitListInitial) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            if (state is HabitListError) {
              return Center(
                child: Text('Error: ${state.message}'),
              );
            }

            final loadedState = state as HabitListLoaded;
            final habits = loadedState.habits;
            final todayLogs = loadedState.todayLogs;
            final streaks = loadedState.streaks;
            final weeklyData = loadedState.weeklyCompletionData;

            final completedToday = todayLogs.values.where((log) => log?.completed == true).length;
            final progress = habits.isEmpty ? 0.0 : completedToday / habits.length;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HabitListBloc>().add(LoadTodayHabitsEvent());
              },
              color: AppTheme.primary,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isDesktop || isTablet) {
                    return Row(
                      children: [
                        SizedBox(
                          width: isDesktop ? 400 : 320,
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildHeader(isTablet: true),
                                      const SizedBox(height: 32),
                                      _buildProgressCard(
                                        completedToday: completedToday,
                                        totalHabits: habits.length,
                                        progress: progress,
                                        isTablet: true,
                                      ),
                                      const SizedBox(height: 24),
                                      _buildWeeklyChart(weeklyData, isTablet: true, habitsCount: habits.length),
                                      const SizedBox(height: 24),
                                      _buildQuickStats(totalHabitsCount: habits.length, activeStreaksCount: streaks.values.where((s) => s > 0).length, todayHabitsCount: habits.length),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 24,
                              right: 24,
                              bottom: 24,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: habits.isEmpty
                                  ? _buildEmptyState(isTablet: true)
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(24),
                                      itemCount: habits.length,
                                      itemBuilder: (context, index) {
                                        final habit = habits[index];
                                        final log = todayLogs[habit.id];
                                        final isCompleted = log?.completed ?? false;
                                        final streak = streaks[habit.id] ?? 0;

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: HabitCard(
                                            id: habit.id,
                                            name: habit.name,
                                            emoji: habit.emoji,
                                            color: Color(habit.colorValue),
                                            streak: streak,
                                            isCompleted: isCompleted,
                                            onToggle: () {
                                              context.read<HabitListBloc>().add(
                                                    ToggleHabitCompletionEvent(habit.id),
                                                  );
                                            },
                                            onEdit: () => _showEditHabitSheet(habit),
                                            onDelete: () {
                                              context.read<HabitListBloc>().add(
                                                    ArchiveHabitEvent(habit.id),
                                                  );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Habit archived'),
                                                  action: SnackBarAction(
                                                    label: 'Undo',
                                                    onPressed: () {
                                                      context.read<HabitListBloc>().add(
                                                            UnarchiveHabitEvent(habit.id),
                                                          );
                                                    },
                                                  ),
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                              );
                                            },
                                          ),
                                        ).animate(delay: (index * 50).ms).fadeIn().slideX();
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(isTablet: false),
                              const SizedBox(height: 20),
                              _buildProgressCard(
                                completedToday: completedToday,
                                totalHabits: habits.length,
                                progress: progress,
                                isTablet: false,
                              ),
                              const SizedBox(height: 20),
                              _buildWeeklyChart(weeklyData, isTablet: false, habitsCount: habits.length),
                            ],
                          ),
                        ),
                      ),
                      habits.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(isTablet: false),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final habit = habits[index];
                                    final log = todayLogs[habit.id];
                                    final isCompleted = log?.completed ?? false;
                                    final streak = streaks[habit.id] ?? 0;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: HabitCard(
                                        id: habit.id,
                                        name: habit.name,
                                        emoji: habit.emoji,
                                        color: Color(habit.colorValue),
                                        streak: streak,
                                        isCompleted: isCompleted,
                                        onToggle: () {
                                          context.read<HabitListBloc>().add(
                                                ToggleHabitCompletionEvent(habit.id),
                                              );
                                        },
                                        onEdit: () => _showEditHabitSheet(habit),
                                        onDelete: () {
                                          context.read<HabitListBloc>().add(
                                                ArchiveHabitEvent(habit.id),
                                              );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Habit archived'),
                                              action: SnackBarAction(
                                                label: 'Undo',
                                                onPressed: () {
                                                  context.read<HabitListBloc>().add(
                                                        UnarchiveHabitEvent(habit.id),
                                                      );
                                                },
                                              ),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          );
                                        },
                                      ),
                                    ).animate(delay: (index * 100).ms).fadeIn().slideY(
                                          begin: 0.2,
                                          end: 0,
                                          duration: 400.ms,
                                          curve: Curves.easeOutQuart,
                                        );
                                  },
                                  childCount: habits.length,
                                ),
                              ),
                            ),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  Widget _buildEmptyState({required bool isTablet}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No habits for today',
            style: isTablet
                ? Theme.of(context).textTheme.displayMedium
                : Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first habit',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isTablet}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Habits',
              style: isTablet
                  ? Theme.of(context).textTheme.displayLarge
                  : Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 16 : 14,
                  ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _showAddHabitSheet,
          child: Container(
            width: isTablet ? 64 : 56,
            height: isTablet ? 64 : 56,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required int completedToday,
    required int totalHabits,
    required double progress,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 28 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completedToday/$totalHabits',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: isTablet ? 12 : 8,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getMotivationalMessage(progress),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<double> data, {required bool isTablet, required int habitsCount}) {
    if (habitsCount == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last 7 Days',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: isTablet ? 18 : 16,
                    ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsPage()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isTablet ? 120 : 80,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppTheme.textPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final dayIndex = (DateTime.now().weekday + groupIndex - 6) % 7;
                      return BarTooltipItem(
                        '${days[dayIndex]}\n${rod.toY.round()}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final dayIndex = (DateTime.now().weekday + value.toInt() - 6) % 7;
                        final isToday = value.toInt() == 6;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[dayIndex],
                            style: TextStyle(
                              color: isToday ? AppTheme.primary : AppTheme.textSecondary,
                              fontSize: isTablet ? 12 : 10,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final isToday = index == 6;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data[index],
                        color: isToday
                            ? AppTheme.primary
                            : AppTheme.primary.withOpacity(0.3),
                        width: isTablet ? 16 : 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildQuickStats({
    required int totalHabitsCount,
    required int activeStreaksCount,
    required int todayHabitsCount,
  }) {
    return Row(
      children: [
        _buildStatItem('Total', '$totalHabitsCount', Icons.folder_outlined),
        const SizedBox(width: 12),
        _buildStatItem('Active', '$activeStreaksCount', Icons.local_fire_department_outlined),
        const SizedBox(width: 12),
        _buildStatItem('Today', '$todayHabitsCount', Icons.today_outlined),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsPage()),
              );
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
