import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:daily_habit/features/auth/presentation/bloc/auth_state.dart';
import 'package:daily_habit/features/auth/presentation/views/login_screen.dart';
import 'package:daily_habit/features/habit/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();

  void _handleAuthAction(bool isAuthenticated) {
    if (isAuthenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _scrollToSection(GlobalKey? key) {
    if (key == null) return;
    try {
      final targetContext = key.currentContext;
      if (targetContext != null && targetContext.mounted) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    } catch (e) {
      // Safe fallback if element is not ready
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // 1. NAVBAR
              _buildNavbar(context, isDesktop),

              // 2. HERO SECTION
              _buildHeroSection(context, isDesktop, isTablet),

              const SizedBox(height: 60),

              // // 3. STATS SHOWCASE (Keunggulan)
              // Container(
              //   key: _statsKey,
              //   child: _buildStatsSection(isDesktop),
              // ),
              // const SizedBox(height: 80),

              // 4. FEATURES SECTION
              Container(
                key: _featuresKey,
                child: _buildFeaturesSection(isDesktop, isTablet),
              ),

              const SizedBox(height: 80),

              // 5. CALL TO ACTION BANNER
              _buildCtaBanner(context, isDesktop),

              const SizedBox(height: 80),

              // 6. FOOTER
              _buildFooter(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. NAVBAR ---
  Widget _buildNavbar(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 20,
      ),
      color: AppTheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Habit & Planner',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isAuthenticated = authState is Authenticated;

              if (isDesktop) {
                return Row(
                  children: [
                    _navLink(
                      'Fitur',
                      onTap: () => _scrollToSection(_featuresKey),
                    ),
                    _navLink(
                      'Keunggulan',
                      onTap: () => _scrollToSection(_statsKey),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton.icon(
                      onPressed: () => _handleAuthAction(isAuthenticated),
                      icon: Icon(
                        isAuthenticated
                            ? Icons.dashboard_rounded
                            : Icons.login_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isAuthenticated ? 'Buka App' : 'Mulai Sekarang',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                );
              } else {
                return IconButton(
                  onPressed: () => _handleAuthAction(isAuthenticated),
                  icon: Icon(
                    isAuthenticated
                        ? Icons.dashboard_rounded
                        : Icons.person_rounded,
                    color: AppTheme.primary,
                  ),
                  tooltip: isAuthenticated
                      ? 'Buka App / Dashboard'
                      : 'Login / Masuk',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _navLink(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // --- 2. HERO SECTION ---
  Widget _buildHeroSection(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
  ) {
    final horizontalPadding = isDesktop ? 64.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 40,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: _buildHeroText(isDesktop: true)),
                const SizedBox(width: 40),
                Expanded(flex: 5, child: _buildHeroPreviewCard()),
              ],
            )
          : Column(
              children: [
                _buildHeroText(isDesktop: false),
                const SizedBox(height: 40),
                _buildHeroPreviewCard(),
              ],
            ),
    );
  }

  Widget _buildHeroText({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : crossAlignmentCenter(isDesktop),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                'Aplikasi Produktivitas All-in-One',
                style: GoogleFonts.outfit(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Bangun Kebiasaan Baik,\nRefleksikan Setiap Momen',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: isDesktop ? 48 : 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Kelola habit harian, atur agenda planner, dan catat refleksi dengan Rich Text Editor yang responsif & tersinkronisasi di semua perangkat.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final isAuthenticated = authState is Authenticated;
                return ElevatedButton.icon(
                  onPressed: () => _handleAuthAction(isAuthenticated),
                  icon: Icon(
                    isAuthenticated
                        ? Icons.dashboard_rounded
                        : Icons.rocket_launch_rounded,
                  ),
                  label: Text(
                    isAuthenticated ? 'Buka Dashboard' : 'Coba Gratis Sekarang',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                );
              },
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: const Text('Lihat Demo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                side: const BorderSide(color: AppTheme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static CrossAxisAlignment crossAlignmentCenter(bool isDesktop) =>
      isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center;

  Widget _buildHeroPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.elevatedShadow,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refleksi Hari Ini',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Kamis, 13 Agustus 2026',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  shape: BoxShape.circle,
                ),
                child: const Text('😄', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.format_quote, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Pelajaran Utama',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Konsistensi jauh lebih penting daripada intensitas yang tidak bertahan lama.',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatTile(
                  'Habit Completed',
                  '8/10',
                  Icons.check_circle,
                  AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatTile(
                  'Streak Current',
                  '14 Hari',
                  Icons.local_fire_department,
                  AppTheme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. STATS SECTION ---
  Widget _buildStatsSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: AppTheme.surface,
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: isDesktop ? 64 : 24,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 32,
        runSpacing: 24,
        children: [
          _buildStatItem('10K+', 'Pengguna Aktif'),
          _buildStatItem('99%', 'Sinkronisasi Realtime'),
          _buildStatItem('4.9 ★', 'Rating Pengalaman UX'),
          _buildStatItem('100%', 'Privasi & Keamanan'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  // --- 4. FEATURES SECTION ---
  Widget _buildFeaturesSection(bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24),
      child: Column(
        children: [
          Text(
            'Fitur Unggulan',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Semua yang kamu butuhkan untuk produktivitas harian dalam satu aplikasi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth =
                  (constraints.maxWidth - (crossAxisCount - 1) * 24) /
                  crossAxisCount;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildFeatureCard(
                    width: cardWidth,
                    icon: Icons.repeat_rounded,
                    color: AppTheme.primary,
                    title: 'Habit Tracker',
                    description:
                        'Atur kebiasaan harian dengan warna visual, reminder, dan tracker streak yang interaktif.',
                  ),
                  _buildFeatureCard(
                    width: cardWidth,
                    icon: Icons.edit_note_rounded,
                    color: AppTheme.success,
                    title: 'Rich Text Reflection',
                    description:
                        'Jurnal harian & catatan refleksi menggunakan editor kaya fitur (bold, italic, list, emoji).',
                  ),
                  _buildFeatureCard(
                    width: cardWidth,
                    icon: Icons.sync_rounded,
                    color: AppTheme.warning,
                    title: 'Offline & Cloud Sync',
                    description:
                        'Data aman tersimpan offline di lokal dan otomatis sinkron saat terhubung ke server backend.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required double width,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. CALL TO ACTION BANNER ---
  Widget _buildCtaBanner(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 56 : 32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppTheme.elevatedShadow,
        ),
        child: Column(
          children: [
            Text(
              'Siap Memulai Perjalanan Produktifmu?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: isDesktop ? 36 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gabung sekarang dan nikmati kemudahan mencatat habit dan refleksi harian.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final isAuthenticated = authState is Authenticated;
                return ElevatedButton(
                  onPressed: () => _handleAuthAction(isAuthenticated),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isAuthenticated
                        ? 'Buka App Sekarang'
                        : 'Mulai Sekarang — Gratis',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. FOOTER ---
  Widget _buildFooter(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: isDesktop ? 64 : 24,
      ),
      color: AppTheme.surface,
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2026 Daily Habit & Planner. All rights reserved.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.language,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.help_outline,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Text(
                  '© 2026 Daily Habit & Planner. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.language,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.help_outline,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
