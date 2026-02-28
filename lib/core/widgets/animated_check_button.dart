import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnimatedCheckButton extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback onTap;
  final Color color;

  const AnimatedCheckButton({
    super.key, 
    required this.isCompleted, 
    required this.onTap, 
    required this.color
  });

  @override
  State<AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<AnimatedCheckButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    // 
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0,end: 0.9).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  @override
  void didUpdateWidget(covariant AnimatedCheckButton oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.isCompleted != oldWidget.isCompleted){
      if(widget.isCompleted){
        _controller.forward().then((_)=>_controller.reverse());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _controller.forward().then((_){
          _controller.reverse();
          widget.onTap();
        });
      },
      child: AnimatedBuilder(animation: _scaleAnimation, builder: (context,child){
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(microseconds: 300),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isCompleted ? widget.color : Colors.transparent,
              border: Border.all(
                color: widget.isCompleted ? widget.color : AppTheme.border,
                width: 2.5,
              ),
              boxShadow: widget.isCompleted ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.isCompleted ?  const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 28,
                        key: ValueKey('checked'),
                      )
                    : Icon(
                        Icons.circle_outlined,
                        color: AppTheme.textSecondary.withOpacity(0.3),
                        size: 24,
                        key: const ValueKey('unchecked'),
                      ),
            ),
          ),
        );
      }),
    );
  }
}