import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool isActive;

  const StreakBadge({
    super.key, 
    required this.streak, 
    required this.isActive
  });

  @override
  Widget build(BuildContext context) {
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive 
            ? AppTheme.warning.withOpacity(0.15) 
            : AppTheme.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '🔥',
              key: ValueKey(streak),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? AppTheme.warning : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}