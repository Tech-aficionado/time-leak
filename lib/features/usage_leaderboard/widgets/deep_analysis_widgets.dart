import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class AppLeakGauge extends StatelessWidget {
  final double leakFactor;

  const AppLeakGauge({super.key, required this.leakFactor});

  @override
  Widget build(BuildContext context) {
    final status = _getLeakStatus();
    final color = _getLeakColor();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LEAK INTENSITY',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            Text(
              '${(leakFactor * 100).toInt()}%',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
               LinearProgressIndicator(
                value: leakFactor,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHighest.withValues(alpha: 0.3),
                color: color,
              ),
              if (leakFactor > 0.8)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1.seconds, color: Colors.white24),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          status,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: color.withValues(alpha: 0.8),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fadeIn(duration: 800.ms).then().fadeOut(duration: 800.ms),
      ],
    );
  }

  Color _getLeakColor() {
    if (leakFactor < 0.3) return AppColors.chronosPurple;
    if (leakFactor < 0.7) return Colors.orangeAccent;
    return AppColors.error;
  }

  String _getLeakStatus() {
    if (leakFactor < 0.3) return 'STABLE FOCUS LAYER';
    if (leakFactor < 0.7) return 'MODERATE EROSION DETECTED';
    return 'CRITICAL ATTENTION RUPTURE';
  }
}

class AppChainCard extends StatelessWidget {
  final String title;
  final List<String> apps;
  final IconData icon;
  final Color color;

  const AppChainCard({
    super.key,
    required this.title,
    required this.apps,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: apps.isEmpty 
            ? Center(
                child: Text(
                  'PROTOCOL STABLE', 
                  style: GoogleFonts.manrope(
                    fontSize: 8, 
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.white10,
                  ),
                ),
              )
            : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
                itemCount: apps.length.clamp(0, 3),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            apps[index].split('.').last.toUpperCase(),
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface.withValues(alpha: 0.9),
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
