import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/core/widgets/habit_card.dart';
import 'package:daily_habit/models/habit_model.dart';
import 'package:daily_habit/presentation/screens/add_habbit_sheet.dart';
import 'package:daily_habit/presentation/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Mock data - replace with your state management
  List<Habit> habits = [
    Habit(
      id: '1',
      name: 'Drink Water',
      emoji: '💧',
      color: AppTheme.habitColors[0],
      streak: 7,
      isCompleted: true,
      frequency: [1, 2, 3, 4, 5, 6, 7],
    ),
    Habit(
      id: '2',
      name: 'Read 20 Minutes',
      emoji: '📚',
      color: AppTheme.habitColors[1],
      streak: 3,
      isCompleted: false,
      frequency: [1, 2, 3, 4, 5],
    ),
    Habit(
      id: '3',
      name: 'Morning Run',
      emoji: '🏃',
      color: AppTheme.habitColors[2],
      streak: 12,
      isCompleted: false,
      frequency: [1, 3, 5],
    ),
    Habit(
      id: '4',
      name: 'Meditate',
      emoji: '🧘',
      color: AppTheme.habitColors[3],
      streak: 0,
      isCompleted: false,
      frequency: [1, 2, 3, 4, 5, 6, 7],
    ),
  ];

  
  void _toggleHabit(String id) {
    setState(() {
      final index = habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        habits[index] = habits[index].copyWith(
          isCompleted: !habits[index].isCompleted,
          streak: habits[index].isCompleted 
              ? habits[index].streak - 1 
              : habits[index].streak + 1,
        );
      }
    });
  }

  
  void _deleteHabit(String id) {
    setState(() {
      habits.removeWhere((h) => h.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Habit deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore logic here
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddHabitSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedToday = habits.where((h) => h.isCompleted).length;
    final progress = habits.isEmpty ? 0.0 : completedToday / habits.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
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
                                  '$completedToday/${habits.length}',
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

            // Habits List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final habit = habits[index];
                  return HabitCard(
                    id: habit.id,
                    name: habit.name,
                    emoji: habit.emoji,
                    color: habit.color,
                    streak: habit.streak,
                    isCompleted: habit.isCompleted,
                    onToggle: () => _toggleHabit(habit.id),
                    onEdit: () {
                      // Show edit sheet
                    },
                    onDelete: () => _deleteHabit(habit.id),
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

            // Bottom padding for nav bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
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