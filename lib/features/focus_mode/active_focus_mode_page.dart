import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeleak/services/focus_mode_service.dart';
import 'package:timeleak/services/neural_lock_service.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'focus_completion_page.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

class ActiveFocusModePage extends StatefulWidget {
  const ActiveFocusModePage({super.key});

  @override
  State<ActiveFocusModePage> createState() => _ActiveFocusModePageState();
}

class _ActiveFocusModePageState extends State<ActiveFocusModePage> with TickerProviderStateMixin {
  late Duration _remaining = Duration.zero;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  final FocusModeService _focusService = FocusModeService();
  final NeuralLockService _lockService = NeuralLockService();
  late StreamSubscription _statusSub;
  late StreamSubscription _kioskSub;
  StreamSubscription? _timeSub;
  late final DateTime _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _remaining = _focusService.activeSession != null 
        ? Duration(milliseconds: _focusService.activeSession!.plannedDurationMs)
        : Duration.zero;
        
    _statusSub = _focusService.statusStream.listen((status) {
      if (status == FocusStatus.completed || status == FocusStatus.interrupted) {
        _showCompletionScreen(
          isSuccess: _focusService.lastSessionSuccess ?? false,
          duration: _focusService.lastSessionDuration,
        );
      }
    });

    _sessionStartTime = DateTime.now();

    _kioskSub = _lockService.kioskModeStream.listen((mode) {
      // Grace period: Ignore "unpinned" status for the first 2 seconds 
      // to allow the Android UI to finish pinning without triggering a breach.
      if (DateTime.now().difference(_sessionStartTime).inSeconds < 2) return;

      if (_focusService.strictMode && mode == KioskMode.disabled && _focusService.currentStatus == FocusStatus.active) {
        _focusService.interruptSession();
      }
    });

    _timeSub = _focusService.remainingStream.listen((time) {
      setState(() => _remaining = time);
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _showCompletionScreen({required bool isSuccess, required Duration duration}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FocusCompletionPage(
          isSuccess: isSuccess,
          actualDuration: duration,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _statusSub.cancel();
    _kioskSub.cancel();
    _timeSub?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes);
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final plannedTotal = _focusService.activeSession?.plannedDurationMs ?? 1;
    final progress = 1.0 - (_remaining.inMilliseconds / plannedTotal);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Navigation while pinned is partially blocked by Android,
        // but this ensures we don't accidentally pop the Flutter route
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Background Atmosphere
            _buildBackgroundAura(),
            
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildMinimalAppBar(),
                  const Spacer(),
                  
                  // Central Timer Engine
                  _buildTimerEngine(progress),
                  
                  const Spacer(),
                  
                  // Status Information
                  _buildProtocolStatus(),
                  const SizedBox(height: 48),
                  
                  // Kill Command
                  _buildKillButton(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundAura() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.chronosPurple.withValues(alpha: 0.05),
              AppColors.background,
            ],
            radius: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEURAL SHIELD',
            style: GoogleFonts.inter(
              color: AppColors.chronosPurpleGlow,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 4),
          Text(
            'Mission Control',
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -1.0,
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildTimerEngine(double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating Energy Ring
        RotationTransition(
          turns: _rotationController,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.chronosPurple.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
        ),
        
        // Progress Arc
        SizedBox(
          width: 280,
          height: 280,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: AppColors.surfaceContainerHighest,
            color: AppColors.chronosPurpleGlow,
          ),
        ),
        
        // Timer Text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(_remaining),
              style: GoogleFonts.manrope(
                fontSize: 72,
                fontWeight: FontWeight.w200,
                color: AppColors.onSurface,
                letterSpacing: -2,
              ),
            ),
            Text(
              'FLOW PERSISTENCE',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: AppColors.chronosPurpleGlow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProtocolStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.chronosPurpleGlow, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEURAL LOCK',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Blocking external distractions.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKillButton() {
    return TextButton(
      onPressed: () {
        // Simple tap nudge
      },
      onLongPress: () => _focusService.interruptSession(),
      child: Column(
        children: [
          Text(
            'ABANDON FLOW',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.redAccent.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '(HOLD TO DEAUTHORIZE)',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.redAccent.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
