import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8FAFC),
                Color(0xFFEEF2FF),
                Color(0xFFF1F5F9),
              ],
            ),
          ),
        ),

        // Glowing Top-Left Ambient Orb
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: 0.25),
                  const Color(0xFF6366F1).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Glowing Bottom-Right Ambient Orb
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Center Ambient Orb
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEC4899).withValues(alpha: 0.15),
                  const Color(0xFFEC4899).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(child: child),
      ],
    );
  }
}
