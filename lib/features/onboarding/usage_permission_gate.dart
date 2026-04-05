import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/usage_stats_service.dart';
import '../../services/usage_tracking_service.dart';
import '../navigation/navigation_container.dart';

/// A gate that ensures PACKAGE_USAGE_STATS permission is granted
/// before showing the main app experience.
/// Re-checks every time the user returns from the system Settings screen.
class UsagePermissionGate extends StatefulWidget {
  const UsagePermissionGate({super.key});

  @override
  State<UsagePermissionGate> createState() => _UsagePermissionGateState();
}

class _UsagePermissionGateState extends State<UsagePermissionGate>
    with WidgetsBindingObserver {
  final UsageStatsService _statsService = UsageStatsService();

  bool _hasPermission = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check when the user returns from the Android Usage Access settings screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_hasPermission) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    setState(() => _isChecking = true);
    final granted = await _statsService.checkPermission();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
        _isChecking = false;
      });
      if (granted) {
        // Start the global data orchestrator now that we know the OS will answer.
        UsageTrackingService().startAutoRefresh();
      }
    }
  }

  Future<void> _requestPermission() async {
    await _statsService.requestPermission();
    // The OS opens the system settings overlay; we will re-check on resume
    // via didChangeAppLifecycleState.
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.chronosPurpleGlow),
        ),
      );
    }

    if (_hasPermission) {
      return const MainNavigationContainer();
    }

    return _PermissionScreen(onGrant: _requestPermission);
  }
}

class _PermissionScreen extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionScreen({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Icon ──────────────────────────────────────────────────────
              _PermissionIcon()
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),

              const Spacer(flex: 3),

              // ── Headline ──────────────────────────────────────────────────
              Text(
                'USAGE ACCESS\nREQUIRED',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 8),

              Text(
                'Time Leak needs access to your device usage statistics to compute your focus score.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
              ).animate(delay: 350.ms).fadeIn(duration: 600.ms),

              const Spacer(flex: 3),

              // ── Steps ─────────────────────────────────────────────────────
              _StepCard(
                stepNumber: '01',
                icon: Icons.settings_outlined,
                title: 'Open Usage Access Settings',
                description: 'Tap the button below to open Android settings.',
              ).animate(delay: 450.ms).fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              _StepCard(
                stepNumber: '02',
                icon: Icons.toggle_on_outlined,
                title: 'Enable Time Leak',
                description:
                    'Find "Time Leak" in the list and toggle it on.',
              ).animate(delay: 550.ms).fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              _StepCard(
                stepNumber: '03',
                icon: Icons.arrow_back_outlined,
                title: 'Return to the App',
                description:
                    'Come back here — the app will update automatically.',
              ).animate(delay: 650.ms).fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

              const Spacer(flex: 4),

              // ── CTA Button ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onGrant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.chronosPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'GRANT USAGE ACCESS',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 750.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              ),

              const Spacer(flex: 2),

              Text(
                'This data never leaves your device without your consent.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ).animate(delay: 850.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow ring
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.chronosPurpleGlow.withValues(alpha: 0.25),
                blurRadius: 48,
                spreadRadius: 12,
              ),
            ],
          ),
        ),
        // Outer ring
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.chronosPurple.withValues(alpha: 0.3),
              width: 1.5,
            ),
            color: AppColors.surfaceContainer,
          ),
        ),
        // Icon
        const Icon(
          Icons.bar_chart_rounded,
          size: 44,
          color: AppColors.chronosPurpleGlow,
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.06, 1.06),
          duration: 2.5.seconds,
          curve: Curves.easeInOut,
        );
  }
}

class _StepCard extends StatelessWidget {
  final String stepNumber;
  final IconData icon;
  final String title;
  final String description;

  const _StepCard({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          // Step badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.chronosPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: GoogleFonts.inter(
                  color: AppColors.chronosPurpleGlow,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, color: AppColors.chronosPurpleGlow, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
