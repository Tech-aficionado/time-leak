import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeleak/core/theme/app_theme.dart';
import 'package:timeleak/core/widgets/glass_card.dart';
import 'package:timeleak/services/focus_mode_service.dart';
import 'package:timeleak/services/neural_lock_service.dart';
import 'package:timeleak/features/navigation/navigation_container.dart';

class FocusCompletionPage extends StatelessWidget {
  final bool isSuccess;
  final Duration actualDuration;

  const FocusCompletionPage({
    super.key, 
    this.isSuccess = true,
    this.actualDuration = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    (isSuccess ? AppColors.chronosPurple : Colors.redAccent).withValues(alpha: 0.1),
                    AppColors.background,
                  ],
                  radius: 1.2,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Central Icon
                  _buildStatusIcon()
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .fadeIn(),
                      
                  const SizedBox(height: 48),
                  
                  // Message
                  Text(
                    isSuccess ? 'MISSION SUCCESS' : 'SHIELD BREACHED',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isSuccess ? AppColors.onSurface : Colors.redAccent,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    isSuccess 
                      ? 'Your neural flow was maintained. Cognitive audit complete.'
                      : 'The strict enforcement protocol was compromised.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 64),
                  
                  // Stats Bento
                  _buildStatsGrid()
                      .animate(delay: 600.ms)
                      .fadeIn()
                      .slideY(begin: 0.1, end: 0),
                  
                  const Spacer(),
                  
                  // Return Command
                  _buildReturnButton(context)
                      .animate(delay: 800.ms)
                      .fadeIn()
                      .scale(begin: const Offset(0.9, 0.9)),
                      
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: (isSuccess ? AppColors.chronosPurple : Colors.redAccent).withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: (isSuccess ? AppColors.chronosPurpleGlow : Colors.redAccent).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? AppColors.chronosPurpleGlow : Colors.redAccent).withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Icon(
        isSuccess ? Icons.check_circle_rounded : Icons.gpp_bad_rounded,
        size: 56,
        color: isSuccess ? AppColors.chronosPurpleGlow : Colors.redAccent,
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'DURATION',
            '${actualDuration.inMinutes} MIN',
            Icons.timer_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            'FLOW SCORE',
            isSuccess ? '+150' : '0',
            Icons.bolt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.chronosPurpleGlow),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.chronosPurple.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          // Robust exit sequence
          await NeuralLockService().disableLock();
          FocusModeService().reset();
          
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainNavigationContainer()),
              (route) => false,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.chronosPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'RETURN TO DASHBOARD',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
