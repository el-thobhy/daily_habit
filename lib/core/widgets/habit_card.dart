import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/core/widgets/animated_check_button.dart';
import 'package:daily_habit/core/widgets/streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitCard extends StatelessWidget {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final int streak;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.streak,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Slidable(
        key: ValueKey(id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.only(left: 8),
              child: const Icon(Icons.delete_outline, size: 24),
            ),
          ],
        ),
        child: GestureDetector(
          onLongPress: onEdit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? color.withOpacity(0.08) 
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted 
                    ? color.withOpacity(0.2) 
                    : AppTheme.border,
                width: 1.5,
              ),
              boxShadow: isCompleted ? [] : AppTheme.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Emoji Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted 
                                ? AppTheme.textSecondary 
                                : AppTheme.textPrimary,
                            decoration: isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        StreakBadge(
                          streak: streak,
                          isActive: isCompleted || streak > 0,
                        ),
                      ],
                    ),
                  ),
                  
                  // Check Button
                  AnimatedCheckButton(
                    isCompleted: isCompleted,
                    onTap: onToggle,
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}