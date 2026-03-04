import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/core/widgets/habit_card.dart';
import 'package:daily_habit/data/services/hive_database.dart';
import 'package:daily_habit/data_model/habit_data_model.dart';
import 'package:daily_habit/data_model/habit_log_model.dart';
import 'package:daily_habit/presentation/screens/add_habbit_sheet.dart';
import 'package:daily_habit/presentation/screens/stats_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final HiveDatabase _db = HiveDatabase();
  final _uuid = const Uuid();
  
  List<HabitDataModel> _habits = [];
  Map<String, HabitLogModel?> _todayLogs = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final habits = _db.getHabitsForToday();
    final today = DateTime.now();
    
    final logs = <String, HabitLogModel?>{};
    for (final habit in habits) {
      logs[habit.id] = _db.getLogForDate(habit.id, today);
    }

    setState(() {
      _habits = habits;
      _todayLogs = logs;
      _isLoading = false;
    });
  }

  Future<void> _toggleHabit(String habitId) async {
    final today = DateTime.now();
    final currentLog = _todayLogs[habitId];
    final newCompleted = !(currentLog?.completed ?? false);

    await _db.logHabit(
      habitId: habitId,
      completed: newCompleted,
      countValue: 1,
    );

    final newStreak = _db.calculateStreak(habitId);

    setState(() {
      _todayLogs[habitId] = HabitLogModel(
        id: '${habitId}_${_formatDate(today)}',
        habitId: habitId,
        date: _formatDate(today),
        completed: newCompleted,
        countValue: 1,
        completedAt: newCompleted ? DateTime.now() : null,
        createdAt: currentLog?.createdAt ?? DateTime.now(),
      );
    });

    if (newCompleted && newStreak > 0 && newStreak % 7 == 0) {
      _showStreakCelebration(newStreak);
    }
  }

  Future<void> _deleteHabit(String habitId) async {
    await _db.archiveHabit(habitId);
    
    setState(() {
      _habits.removeWhere((h) => h.id == habitId);
      _todayLogs.remove(habitId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Habit archived'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              final habit = _db.habitsBox.get(habitId);
              if (habit != null) {
                habit.isArchived = false;
                await habit.save();
                await _loadData();
              }
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _addHabit(Map<String, dynamic> data) async {
    final habit = HabitDataModel(
      id: _uuid.v4(),
      name: data['name'],
      emoji: data['emoji'],
      colorValue: data['color'].value,
      frequency: data['frequency'],
      reminderTime: data['reminderTime'],
      targetCount: data['targetCount'] ?? 1,
      unit: data['unit'],
      categoryId: data['categoryId'],
      sortOrder: _habits.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _db.createHabit(habit);
    await _loadData();
  }

  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitSheet(
        onSave: _addHabit,
      ),
    );
  }

  void _showEditHabitSheet(HabitDataModel habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitSheet(
        habit: habit,
        onSave: (data) async {
          final updated = HabitDataModel(
            id: habit.id,
            name: data['name'],
            emoji: data['emoji'],
            colorValue: data['color'].value,
            frequency: data['frequency'],
            reminderTime: data['reminderTime'],
            targetCount: data['targetCount'] ?? 1,
            unit: data['unit'],
            categoryId: data['categoryId'],
            sortOrder: habit.sortOrder,
            isArchived: habit.isArchived,
            createdAt: habit.createdAt,
            updatedAt: DateTime.now(),
          );
          await _db.updateHabit(updated);
          await _loadData();
        },
      ),
    );
  }

  void _showStreakCelebration(int streak) {
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
              '$streak Day Streak!',
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _getStreak(String habitId) {
    return _db.calculateStreak(habitId);
  }

  List<double> _getWeeklyCompletionData() {
    final data = <double>[];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLogs = _db.getLogsForDate(date);
      final completed = dayLogs.where((log) => log?.completed == true).length;
      final total = _habits.where((h) => 
        h.frequency.contains(date.weekday)
      ).length;
      
      data.add(total > 0 ? (completed / total) * 100 : 0);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completedToday = _todayLogs.values.where((log) => log?.completed == true).length;
    final progress = _habits.isEmpty ? 0.0 : completedToday / _habits.length;
    final weeklyData = _getWeeklyCompletionData();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Desktop/Tablet Layout - Use CustomScrollView with slivers
              if (isDesktop || isTablet) {
                return Row(
                  children: [
                    // Left Panel - Fixed width, scrollable content
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
                                    progress: progress,
                                    isTablet: true,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildWeeklyChart(weeklyData, isTablet: true),
                                  const SizedBox(height: 24),
                                  _buildQuickStats(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Right Panel - Habits List
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
                          child: _habits.isEmpty
                              ? _buildEmptyState(isTablet: true)
                              : ListView.builder(
                                  padding: const EdgeInsets.all(24),
                                  itemCount: _habits.length,
                                  itemBuilder: (context, index) {
                                    final habit = _habits[index];
                                    final log = _todayLogs[habit.id];
                                    final isCompleted = log?.completed ?? false;
                                    final streak = _getStreak(habit.id);

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: HabitCard(
                                        id: habit.id,
                                        name: habit.name,
                                        emoji: habit.emoji,
                                        color: Color(habit.colorValue),
                                        streak: streak,
                                        isCompleted: isCompleted,
                                        onToggle: () => _toggleHabit(habit.id),
                                        onEdit: () => _showEditHabitSheet(habit),
                                        onDelete: () => _deleteHabit(habit.id),
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

              // Mobile Layout - Use CustomScrollView throughout
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
                            progress: progress,
                            isTablet: false,
                          ),
                          const SizedBox(height: 20),
                          _buildWeeklyChart(weeklyData, isTablet: false),
                        ],
                      ),
                    ),
                  ),
                  // Empty state or list as sliver
                  _habits.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(isTablet: false),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final habit = _habits[index];
                                final log = _todayLogs[habit.id];
                                final isCompleted = log?.completed ?? false;
                                final streak = _getStreak(habit.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: HabitCard(
                                    id: habit.id,
                                    name: habit.name,
                                    emoji: habit.emoji,
                                    color: Color(habit.colorValue),
                                    streak: streak,
                                    isCompleted: isCompleted,
                                    onToggle: () => _toggleHabit(habit.id),
                                    onEdit: () => _showEditHabitSheet(habit),
                                    onDelete: () => _deleteHabit(habit.id),
                                  ),
                                ).animate(delay: (index * 100).ms).fadeIn().slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 400.ms,
                                      curve: Curves.easeOutQuart,
                                    );
                              },
                              childCount: _habits.length,
                            ),
                          ),
                        ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              );
            },
          ),
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
                  '$completedToday/${_habits.length}',
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

  Widget _buildWeeklyChart(List<double> data, {required bool isTablet}) {
    if (_habits.isEmpty) return const SizedBox.shrink();

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
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
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
                  child: Row(
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
                      const SizedBox(width: 4),
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

  Widget _buildQuickStats() {
    final totalHabits = _db.getAllHabits().length;
    final activeStreaks = _habits.where((h) => _getStreak(h.id) > 0).length;

    return Row(
      children: [
        _buildStatItem('Total', '$totalHabits', Icons.folder_outlined),
        const SizedBox(width: 12),
        _buildStatItem('Active', '$activeStreaks', Icons.local_fire_department_outlined),
        const SizedBox(width: 12),
        _buildStatItem('Today', '${_habits.length}', Icons.today_outlined),
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
                MaterialPageRoute(builder: (_) => const StatsScreen()),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! ☀️';
    if (hour < 17) return 'Good afternoon! 🌤';
    return 'Good evening! 🌙';
  }

  String _getMotivationalMessage(double progress) {
    if (progress == 0) return 'Start your day strong! 💪';
    if (progress < 0.5) return 'Keep going, you\'re doing great!';
    if (progress < 1) return 'Almost there! 🔥';
    return 'All done! Amazing job! 🎉';
  }
}