import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/data/services/hive_database.dart';
import 'package:daily_habit/data_model/habit_data_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final HiveDatabase _db = HiveDatabase();
  
  bool _isLoading = true;
  List<HabitDataModel> _habits = [];
  Map<String, int> _streaks = {};
  Map<String, List<double>> _weeklyData = {};
  
  // Overall stats
  int _totalCurrentStreak = 0;
  double _weeklyCompletionRate = 0.0;
  int _bestStreak = 0;
  String _bestStreakHabitName = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final habits = _db.getAllHabits();
    final now = DateTime.now();
    
    // Calculate streaks for all habits
    final streaks = <String, int>{};
    final weeklyData = <String, List<double>>{};
    
    int totalStreak = 0;
    int bestStreak = 0;
    String bestHabit = '';

    for (final habit in habits) {
      // Get streak
      final streak = _db.calculateStreak(habit.id);
      streaks[habit.id] = streak;
      totalStreak += streak;
      
      // Track best streak
      if (streak > bestStreak) {
        bestStreak = streak;
        bestHabit = habit.name;
      }

      // Get weekly completion data (last 7 days)
      final weekData = <double>[];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final log = _db.getLogForDate(habit.id, date);
        weekData.add(log?.completed == true ? 100.0 : 0.0);
      }
      weeklyData[habit.id] = weekData;
    }

    // Calculate weekly completion rate across all habits
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStats = _db.getStatsForRange(weekStart, now);
    final completionRate = (weekStats['rate'] as int).toDouble();

    setState(() {
      _habits = habits;
      _streaks = streaks;
      _weeklyData = weeklyData;
      _totalCurrentStreak = totalStreak;
      _weeklyCompletionRate = completionRate;
      _bestStreak = bestStreak;
      _bestStreakHabitName = bestHabit;
      _isLoading = false;
    });
  }

  // Calculate average completion per day for chart
  List<double> _getAverageWeeklyData() {
    if (_habits.isEmpty) return [0, 0, 0, 0, 0, 0, 0];
    
    final averages = <double>[];
    for (int day = 0; day < 7; day++) {
      double total = 0;
      for (final habit in _habits) {
        total += _weeklyData[habit.id]?[day] ?? 0;
      }
      averages.add(total / _habits.length);
    }
    return averages;
  }

  // Get top 3 habits by streak
  List<Map<String, dynamic>> _getTopStreaks() {
    final sorted = _habits.toList()
      ..sort((a, b) => (_streaks[b.id] ?? 0).compareTo(_streaks[a.id] ?? 0));
    
    return sorted.take(3).map((habit) => {
      'name': habit.name,
      'streak': _streaks[habit.id] ?? 0,
      'color': Color(habit.colorValue),
    }).toList();
  }

  String _formatStreakSubtitle() {
    if (_bestStreak == 0) return 'Start building habits!';
    return 'Best: $_bestStreakHabitName ($_bestStreak)';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final weeklyAverages = _getAverageWeeklyData();
    final topStreaks = _getTopStreaks();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
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
            onPressed: _loadStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Summary Cards
              Row(
                children: [
                  _buildSummaryCard(
                    'Total Streaks',
                    '${_habits.isEmpty ? 0 : _totalCurrentStreak}',
                    _formatStreakSubtitle(),
                    AppTheme.warning,
                    Icons.local_fire_department_rounded,
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(width: 16),
                  _buildSummaryCard(
                    'This Week',
                    '${_weeklyCompletionRate.round()}%',
                    'completion rate',
                    AppTheme.success,
                    Icons.check_circle_rounded,
                  ).animate().fadeIn().slideX(begin: 0.2, end: 0),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly Chart
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
                        if (_habits.isNotEmpty)
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
                              '${_habits.length} habits',
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
                      child: _habits.isEmpty
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

              // Best Streaks
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
              
              // Additional Stats Grid
              if (_habits.isNotEmpty) _buildAdditionalStats(),
            ],
          ),
        ),
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
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
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

  Widget _buildAdditionalStats() {
    // Calculate additional metrics
    final totalHabits = _habits.length;
    final activeHabits = _habits.where((h) => !h.isArchived).length;
    final habitsWithStreak = _streaks.values.where((s) => s > 0).length;
    
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