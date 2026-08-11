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
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.streak,
    this.isCompleted = false,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Slidable(
        key: ValueKey(id),
        endActionPane: onDelete != null
            ? ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.25,
                children: [
                  CustomSlidableAction(
                    onPressed: (_) => onDelete!(),
                    backgroundColor: AppTheme.danger,
                    foregroundColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.only(left: 8),
                    child: const Icon(Icons.delete_outline, size: 24),
                  ),
                ],
              )
            : null,
        child: GestureDetector(
          onTap: onEdit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isCompleted
                  ? color.withValues(alpha: 0.08)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? color.withValues(alpha: 0.2)
                    : AppTheme.border,
                width: 1.5,
              ),
              boxShadow: isCompleted ? [] : AppTheme.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
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
                  if (onToggle != null)
                    AnimatedCheckButton(
                      isCompleted: isCompleted,
                      onTap: onToggle!,
                      color: color,
                    )
                  else if (onEdit != null || onDelete != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: onEdit,
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: AppTheme.danger,
                            ),
                            onPressed: onDelete,
                          ),
                      ],
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
