import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/core/widgets/habit_card.dart';
import 'package:daily_habit/features/habit/domain/entities/habit_entity.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_bloc.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_event.dart';
import 'package:daily_habit/features/habit/presentation/bloc/habit_list/habit_list_state.dart';
import 'package:daily_habit/features/habit/presentation/pages/stats_page.dart';
import 'package:daily_habit/features/habit/presentation/widgets/add_habit_sheet.dart';
import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';
import 'package:daily_habit/features/planner/domain/entities/planner_task_entity.dart';
import 'package:daily_habit/features/planner/presentation/bloc/planner/planner_bloc.dart';
import 'package:daily_habit/features/planner/presentation/bloc/planner/planner_event.dart';
import 'package:daily_habit/features/planner/presentation/bloc/planner/planner_state.dart';
import 'package:daily_habit/features/planner/presentation/bloc/reflection/reflection_bloc.dart';
import 'package:daily_habit/features/planner/presentation/bloc/reflection/reflection_event.dart';
import 'package:daily_habit/features/planner/presentation/bloc/reflection/reflection_state.dart';
import 'package:daily_habit/features/planner/presentation/widgets/add_planner_task_sheet.dart';
import 'package:daily_habit/features/planner/presentation/widgets/calendar_header_widget.dart';
import 'package:daily_habit/features/planner/presentation/widgets/daily_reflection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadDataForSelectedDate(_selectedDate);
  }

  void _loadDataForSelectedDate(DateTime date) {
    context.read<HabitListBloc>().add(LoadTodayHabitsEvent());
    context.read<PlannerBloc>().add(LoadPlannerTasksForDate(date));
    context.read<ReflectionBloc>().add(LoadReflectionForDate(date));
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadDataForSelectedDate(date);
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

  void _showAddPlannerTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPlannerTaskSheet(
        selectedDate: _selectedDate,
        onTaskAdded: (task) {
          context.read<PlannerBloc>().add(AddPlannerTaskEvent(task));
        },
      ),
    );
  }

  void _showReflectionSheet(DailyReflectionEntity? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DailyReflectionSheet(
        date: _selectedDate,
        existingReflection: existing,
        onSave: (reflection) {
          context.read<ReflectionBloc>().add(SaveReflectionEvent(reflection));
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi ☀️';
    if (hour < 17) return 'Selamat Siang 🌤️';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) _buildSidebarNav(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildPlannerTab(),
                  _buildHabitsTab(),
                  const StatsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  // --- DESKTOP SIDEBAR NAVIGATION ---
  Widget _buildSidebarNav() {
    return Container(
      width: 240,
      color: AppTheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 28),
              const SizedBox(width: 10),
              Text(
                'Daily Planner',
                style: AppTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildSidebarItem(0, Icons.calendar_today_rounded, 'Planner & Reflection'),
          _buildSidebarItem(1, Icons.check_circle_outline_rounded, 'Kelola Habits'),
          _buildSidebarItem(2, Icons.insights_rounded, 'Stats & Analysis'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: DAILY PLANNER & REFLECTIONS ---
  Widget _buildPlannerTab() {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width > 768;

    return RefreshIndicator(
      onRefresh: () async {
        _loadDataForSelectedDate(_selectedDate);
      },
      color: AppTheme.primary,
      child: isWideScreen
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(formattedDate),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Calendar & Reflections
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                CalendarHeaderWidget(
                                  selectedDay: _selectedDate,
                                  onDaySelected: _onDateSelected,
                                ),
                                const SizedBox(height: 20),
                                _buildReflectionCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right Column: Habits & Tasks
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                _buildHabitSectionHeader(),
                                const SizedBox(height: 12),
                                _buildHabitsListContent(),
                                const SizedBox(height: 24),
                                _buildTaskSectionHeader(),
                                const SizedBox(height: 12),
                                _buildTasksListContent(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(formattedDate),
                        const SizedBox(height: 12),
                        CalendarHeaderWidget(
                          selectedDay: _selectedDate,
                          onDaySelected: _onDateSelected,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildHabitSectionHeader(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: _buildHabitsListSliver(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTaskSectionHeader(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: _buildTasksListSliver(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: AppTheme.warning, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Pelajaran & Refleksi Hari Ini',
                          style: AppTheme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildReflectionCard(),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
    );
  }

  Widget _buildHeaderSection(String formattedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Planner',
                style: AppTheme.textTheme.displayMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _getGreeting(),
                style: AppTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formattedDate,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.repeat, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Habit Tetap Harian',
              style: AppTheme.textTheme.titleLarge,
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _showAddHabitSheet,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Habit'),
        ),
      ],
    );
  }

  Widget _buildTaskSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.task_alt, color: AppTheme.success, size: 20),
            const SizedBox(width: 8),
            Text(
              'Agenda & Task',
              style: AppTheme.textTheme.titleLarge,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddPlannerTaskSheet,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Tambah Task'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsListContent() {
    return BlocBuilder<HabitListBloc, HabitListState>(
      builder: (context, state) {
        if (state is HabitListLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HabitListLoaded) {
          final habits = state.habits;
          if (habits.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Belum ada habit harian. Tambahkan habit tetap Anda.',
                style: AppTheme.textTheme.bodyMedium,
              ),
            );
          }
          return Column(
            children: habits.map((habit) {
              final isCompleted = state.todayLogs[habit.id]?.completed ?? false;
              final streak = state.streaks[habit.id] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHabitsListSliver() {
    return BlocBuilder<HabitListBloc, HabitListState>(
      builder: (context, state) {
        if (state is HabitListLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (state is HabitListLoaded) {
          final habits = state.habits;
          if (habits.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Belum ada habit harian. Tambahkan habit tetap Anda.',
                  style: AppTheme.textTheme.bodyMedium,
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final habit = habits[index];
                final isCompleted = state.todayLogs[habit.id]?.completed ?? false;
                final streak = state.streaks[habit.id] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                  ),
                );
              },
              childCount: habits.length,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildTasksListContent() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        if (state is PlannerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PlannerLoaded) {
          final tasks = state.tasks;
          if (tasks.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.event_note, size: 40, color: AppTheme.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada aktivitas khusus untuk tanggal ini',
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          return Column(
            children: tasks.map((task) => _buildTaskTile(task)).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTasksListSliver() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        if (state is PlannerLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (state is PlannerLoaded) {
          final tasks = state.tasks;
          if (tasks.isEmpty) {
            return SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.event_note, size: 40, color: AppTheme.textSecondary),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada aktivitas khusus untuk tanggal ini',
                      style: AppTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = tasks[index];
                return _buildTaskTile(task);
              },
              childCount: tasks.length,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildReflectionCard() {
    return BlocBuilder<ReflectionBloc, ReflectionState>(
      builder: (context, state) {
        DailyReflectionEntity? reflection;
        if (state is ReflectionLoaded) {
          reflection = state.reflection;
        }

        final hasContent = reflection != null &&
            (reflection.todayLesson.isNotEmpty || reflection.memorableNotes.isNotEmpty);

        return GestureDetector(
          onTap: () => _showReflectionSheet(reflection),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.surface,
                  AppTheme.background,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
              border: Border.all(
                color: hasContent ? AppTheme.primaryLight : AppTheme.border,
                width: hasContent ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '💡 Learning Everyday',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!hasContent) ...[
                  Text(
                    'Belum ada catatan refleksi atau pelajaran untuk hari ini.',
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klik di sini untuk menulis pelajaran & momen berkesan hari ini ✨',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ] else ...[
                  if (reflection.todayLesson.isNotEmpty) ...[
                    Text(
                      'Pelajaran Hari Ini:',
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reflection.todayLesson,
                      style: AppTheme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (reflection.memorableNotes.isNotEmpty) ...[
                    Text(
                      'Catatan Berkesan:',
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reflection.memorableNotes,
                      style: AppTheme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskTile(PlannerTaskEntity task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: AppTheme.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (_) {
              context.read<PlannerBloc>().add(TogglePlannerTaskEvent(task));
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
                  ),
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description!,
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (task.timeString != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.timeString!,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
            onPressed: () {
              context.read<PlannerBloc>().add(
                    DeletePlannerTaskEvent(taskId: task.id, currentDate: _selectedDate),
                  );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 2: HABITS MANAGER ---
  Widget _buildHabitsTab() {
    return BlocBuilder<HabitListBloc, HabitListState>(
      builder: (context, state) {
        if (state is HabitListLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HabitListLoaded) {
          final habits = state.habits;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kelola Habit Harian',
                        style: AppTheme.textTheme.displayMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _showAddHabitSheet,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Habit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: habits.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada habit',
                          style: AppTheme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 100),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HabitCard(
                              id: habit.id,
                              name: habit.name,
                              emoji: habit.emoji,
                              color: Color(habit.colorValue),
                              streak: state.streaks[habit.id] ?? 0,
                              isCompleted: state.todayLogs[habit.id]?.completed ?? false,
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
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // --- BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
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
            setState(() => _selectedIndex = index);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Planner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline_rounded),
              label: 'Habits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
