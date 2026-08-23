import 'package:daily_habit/core/di/injection_container.dart';
import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/core/widgets/ad_banner_widget.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_stats/habit_stats_bloc.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_stats/habit_stats_event.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_stats/habit_stats_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HabitStatsBloc>()..add(LoadHabitStatsEvent()),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  List<double> _getAverageWeeklyData(HabitStatsLoaded state) {
    if (state.habits.isEmpty) return [0, 0, 0, 0, 0, 0, 0];

    final averages = <double>[];
    for (int day = 0; day < 7; day++) {
      double total = 0;
      for (final habit in state.habits) {
        total += state.weeklyData[habit.id]?[day] ?? 0;
      }
      averages.add(total / state.habits.length);
    }
    return averages;
  }

  List<Map<String, dynamic>> _getTopStreaks(HabitStatsLoaded state) {
    final sorted = state.habits.toList()
      ..sort((a, b) => (state.streaks[b.id] ?? 0).compareTo(state.streaks[a.id] ?? 0));

    return sorted.take(3).map((habit) => {
      'name': habit.name,
      'streak': state.streaks[habit.id] ?? 0,
      'color': Color(habit.colorValue),
    }).toList();
  }

  String _formatStreakSubtitle(int bestStreak, String bestStreakHabitName) {
    if (bestStreak == 0) return 'Start building habits!';
    return 'Best: $bestStreakHabitName ($bestStreak)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Statistics',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 20,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: () => context.read<HabitStatsBloc>().add(LoadHabitStatsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<HabitStatsBloc, HabitStatsState>(
        builder: (context, state) {
          if (state is HabitStatsLoading || state is HabitStatsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (state is HabitStatsError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          final loadedState = state as HabitStatsLoaded;
          final weeklyAverages = _getAverageWeeklyData(loadedState);
          final topStreaks = _getTopStreaks(loadedState);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HabitStatsBloc>().add(LoadHabitStatsEvent());
            },
            color: AppTheme.primary,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Total Streaks',
                        '${loadedState.habits.isEmpty ? 0 : loadedState.totalCurrentStreak}',
                        _formatStreakSubtitle(loadedState.bestStreak, loadedState.bestStreakHabitName),
                        AppTheme.warning,
                        Icons.local_fire_department_rounded,
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      const SizedBox(width: 16),
                      _buildSummaryCard(
                        'This Week',
                        '${loadedState.weeklyCompletionRate.round()}%',
                        'completion rate',
                        AppTheme.success,
                        Icons.check_circle_rounded,
                      ).animate().fadeIn().slideX(begin: 0.2, end: 0),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weekly Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (loadedState.habits.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${loadedState.habits.length} habits',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Average completion across all habits',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: loadedState.habits.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bar_chart_outlined,
                                        size: 48,
                                        color: AppTheme.textSecondary.withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No data yet',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: 100,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipBgColor: AppTheme.textPrimary,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                          return BarTooltipItem(
                                            '${days[groupIndex]}\n${rod.toY.round()}%',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
                                          getTitlesWidget: (value, meta) {
                                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                            final isToday = value.toInt() == DateTime.now().weekday - 1;
                                            return Text(
                                              days[value.toInt()],
                                              style: TextStyle(
                                                color: isToday ? AppTheme.primary : AppTheme.textSecondary,
                                                fontSize: 12,
                                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 25,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: AppTheme.border.withOpacity(0.5),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(7, (index) {
                                      final value = weeklyAverages[index];
                                      final isToday = index == DateTime.now().weekday - 1;
                                      return _buildBarGroup(
                                        index,
                                        value,
                                        isToday ? AppTheme.primary : AppTheme.primaryLight,
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Top Streaks',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (topStreaks.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text('🔥', style: TextStyle(fontSize: 16)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (topStreaks.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text('🏃', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No streaks yet!',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Complete habits daily to build streaks',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...topStreaks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final streak = entry.value;
                            return _buildStreakItem(
                              streak['name'] as String,
                              streak['streak'] as int,
                              streak['color'] as Color,
                              index + 1,
                            ).animate(delay: (index * 100).ms).fadeIn().slideX();
                          }),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),
                  const AdBannerWidget(),
                  const SizedBox(height: 24),

                  if (loadedState.habits.isNotEmpty)
                    _buildAdditionalStats(context, loadedState),
                ],
              ),
            ),
          ),
        ),
      );
    },
  ),
);
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    final validY = y.isNaN || y.isInfinite ? 0.0 : y.clamp(0.0, 100.0);
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: validY,
          color: color,
          width: 22,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: AppTheme.background,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakItem(String name, int days, Color color, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AppTheme.warning.withOpacity(0.2)
                  : AppTheme.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? AppTheme.warning : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (rank == 1)
                  Text(
                    'Personal best! 🔥',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: days > 0
                  ? AppTheme.warning.withOpacity(0.15)
                  : AppTheme.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  days > 0 ? '🔥' : '⚪',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  '$days',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: days > 0 ? AppTheme.warning : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalStats(BuildContext context, HabitStatsLoaded state) {
    final totalHabits = state.habits.length;
    final activeHabits = state.habits.where((h) => !h.isArchived).length;
    final habitsWithStreak = state.streaks.values.where((s) => s > 0).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildMiniStat('Active', '$activeHabits', Icons.track_changes),
            _buildMiniStat('With Streak', '$habitsWithStreak', Icons.trending_up),
            _buildMiniStat('Total', '$totalHabits', Icons.folder_outlined),
          ],
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border.withOpacity(0.5)),
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
                fontSize: 11,
                color: AppTheme.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
