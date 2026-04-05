import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeleak/core/theme/app_theme.dart';
import 'package:timeleak/core/widgets/glass_card.dart';
import 'package:timeleak/services/auth_service.dart';
import 'package:timeleak/services/auth_service.dart';
import 'package:toastification/toastification.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final creds = await authService.signInWithGoogle();

      if (mounted) {
        if (creds != null && creds.user != null) {
          toastification.show(
            context: context,
            title: const Text('Authentication Initiated'),
            description: const Text('Protocol established. Syncing profile...'),
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.topCenter,
            showProgressBar: false,
          );
          // No manual navigation here!
          // main.dart's StreamBuilder will catch the auth state change
          // and automatically show the UsagePermissionGate.
        } else {
          setState(() => _isLoading = false);
          toastification.show(
            context: context,
            title: const Text('Protocol Interrupted'),
            description: const Text('Failed to sign in with Google.'),
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.topCenter,
            showProgressBar: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('[LandingPage] Sign-in error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Immersive Background
          Positioned.fill(
            child: Container(
              color: Colors.black,
            ),
          ),
          
          // Scanline Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _ScanlinePainter(),
            ),
          ),
          
          // Animated Nebula Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _AnimatedBlob(
              color: AppColors.chronosPurpleGlow.withValues(alpha: 0.3),
              size: 500,
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(begin: const Offset(-20, -20), end: const Offset(20, 20), duration: 10.seconds, curve: Curves.easeInOut),
          ),
          
          Positioned(
            bottom: -150,
            left: -100,
            child: _AnimatedBlob(
              color: Colors.blueAccent.withValues(alpha: 0.2),
              size: 600,
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(begin: const Offset(20, 20), end: const Offset(-20, -20), duration: 12.seconds, curve: Curves.easeInOut),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  
                  // App Branding
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.chronosPurpleGlow.withValues(alpha: 0.2)),
                            ),
                          ).animate(onPlay: (c) => c.repeat())
                           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds, curve: Curves.easeInOut)
                           .fadeOut(begin: 0.2, duration: 2.seconds),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.chronosPurpleGlow.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.chronosPurpleGlow.withValues(alpha: 0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.chronosPurpleGlow.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.hourglass_empty_rounded,
                              size: 32,
                              color: AppColors.chronosPurpleGlow,
                            ),
                          ).animate()
                           .scale(duration: 800.ms, curve: Curves.easeOutBack)
                           .shimmer(delay: 1.seconds, duration: 2.seconds),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'CHRONOS',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
                    ],
                  ),
                  
                  // Primary Headline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Colors.white70],
                        ).createShader(bounds),
                        child: Text(
                          'RECLAIM',
                          style: GoogleFonts.manrope(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                            letterSpacing: -2,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
                      
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.chronosPurpleGlow, Colors.blueAccent],
                        ).createShader(bounds),
                        child: Text(
                          'STREAMS',
                          style: GoogleFonts.manrope(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                            letterSpacing: -2,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Deploying focus protocols to optimize your digital presence. Eliminate temporal leaks.',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Feature Matrix
                  const _FeatureGrid(),
                  
                  const Spacer(),
                  
                  // Immersive CTA
                  _CommandButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    isLoading: _isLoading,
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AnimatedBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _FeatureCard(
          icon: Icons.psychology_outlined,
          title: 'NEURAL SYNC',
          subtitle: 'Biometric tracking',
          index: 0,
        ),
        _FeatureCard(
          icon: Icons.shield_outlined,
          title: 'TEMPORAL ARMOR',
          subtitle: 'Focus protocols',
          index: 1,
        ),
        _FeatureCard(
          icon: Icons.analytics_outlined,
          title: 'REGISTRY',
          subtitle: 'Live leak leaderboard',
          index: 2,
        ),
        _FeatureCard(
          icon: Icons.auto_awesome_outlined,
          title: 'GHOST INTEL',
          subtitle: 'AI behavior scans',
          index: 3,
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int index;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.chronosPurpleGlow, size: 20),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat())
               .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 1.seconds, curve: Curves.easeInOut)
               .then().scale(begin: const Offset(1.5, 1.5), end: const Offset(1, 1), duration: 1.seconds),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (600 + (index * 100)).ms, duration: 600.ms).slideX(begin: 0.1);
  }
}

class _CommandButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _CommandButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.chronosPurpleGlow,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.chronosPurpleGlow, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'INITIATE PROTOCOL',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat())
      .shimmer(delay: 2.seconds, duration: 1.5.seconds, color: Colors.white12);
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
