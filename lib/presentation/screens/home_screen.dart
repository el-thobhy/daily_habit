import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/core/widgets/habit_card.dart';
import 'package:daily_habit/data/services/hive_database.dart';
import 'package:daily_habit/data_model/habit_data_model.dart';
import 'package:daily_habit/data_model/habit_log_model.dart';
import 'package:daily_habit/presentation/screens/add_habbit_sheet.dart';
import 'package:daily_habit/presentation/screens/stats_screen.dart';
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
  
  // Local state for UI - mirrors database
  List<HabitDataModel> _habits = [];
  Map<String, HabitLogModel?> _todayLogs = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==================== DATA LOADING ====================

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Get habits for today based on frequency
    final habits = _db.getHabitsForToday();
    final today = DateTime.now();
    
    // Get completion status for each habit
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

  // ==================== HABIT OPERATIONS ====================

  Future<void> _toggleHabit(String habitId) async {
    final today = DateTime.now();
    final currentLog = _todayLogs[habitId];
    final newCompleted = !(currentLog?.completed ?? false);

    // Update database
    await _db.logHabit(
      habitId: habitId,
      completed: newCompleted,
      countValue: 1,
    );

    // Recalculate streak
    final newStreak = _db.calculateStreak(habitId);

    // Update local state for instant UI feedback
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

    // Optional: Show streak celebration
    if (newCompleted && newStreak > 0 && newStreak % 7 == 0) {
      _showStreakCelebration(newStreak);
    }
  }

  Future<void> _deleteHabit(String habitId) async {
    // Archive instead of hard delete (keeps history)
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
              // Restore by unarchiving
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
    await _loadData(); // Refresh list
  }

  // ==================== UI HELPERS ====================

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

  // Get streak for display (calculated on demand or cached)
  int _getStreak(String habitId) {
    return _db.calculateStreak(habitId);
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completedToday = _todayLogs.values.where((log) => log?.completed == true).length;
    final progress = _habits.isEmpty ? 0.0 : completedToday / _habits.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Habits',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getGreeting(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _showAddHabitSheet,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(20),
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
                      ),
                      const SizedBox(height: 24),
                      
                      // Daily Progress Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primaryLight,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
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
                                    fontSize: 14,
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
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getMotivationalMessage(progress),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Empty State
              if (_habits.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          'No habits for today',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create your first habit',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

              // Habits List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = _habits[index];
                    final log = _todayLogs[habit.id];
                    final isCompleted = log?.completed ?? false;
                    final streak = _getStreak(habit.id);

                    return HabitCard(
                      id: habit.id,
                      name: habit.name,
                      emoji: habit.emoji,
                      color: Color(habit.colorValue),
                      streak: streak,
                      isCompleted: isCompleted,
                      onToggle: () => _toggleHabit(habit.id),
                      onEdit: () => _showEditHabitSheet(habit),
                      onDelete: () => _deleteHabit(habit.id),
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

              // Bottom padding for nav bar
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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