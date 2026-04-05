import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/focus_mode_service.dart';
import '../../services/neural_lock_service.dart';
import 'active_focus_mode_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> with SingleTickerProviderStateMixin {
  int _selectedMinutes = 25;
  bool _isStrict = true;
  late AnimationController _pulseController;
  final FocusModeService _focusService = FocusModeService();
  final NeuralLockService _lockService = NeuralLockService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    // Check if session already active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusService.currentStatus == FocusStatus.active) {
        _navigateToActiveFocus();
      }
    });
  }

  void _navigateToActiveFocus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ActiveFocusModePage(),
      ),
    );
  }

  Future<void> _showPermissionDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DND Access Required'),
        content: const Text('Strict mode requires Do Not Disturb access to silence notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _lockService.requestDndAccess();
              Navigator.pop(context);
            },
            child: const Text('Grant Access'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 40),
                _buildFocusOrb()
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                const SizedBox(height: 60),
                _buildProtocolCard()
                    .animate(delay: 200.ms)
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 24),
                _buildDurationSelector()
                    .animate(delay: 400.ms)
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 48),
                _buildStartButton()
                    .animate(delay: 600.ms)
                    .fadeIn()
                    .scale(begin: const Offset(0.9, 0.9)),
                const SizedBox(height: 120), // Height for FloatingNavBar
                const SizedBox(height: 40), // Additional clearance for button
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      collapsedHeight: 70.0,
      pinned: true,
      floating: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEURAL SHIELD',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: AppColors.chronosPurpleGlow,
              ).copyWith(shadows: [
                Shadow(
                  color: AppColors.chronosPurpleGlow.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ]),
            ),
            const SizedBox(height: 2),
            Text(
              'Mission Control',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.onSurface,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms),
      ),
    );
  }

  Widget _buildFocusOrb() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Static Concentric Guide Rings
          ...List.generate(4, (index) {
            final radius = 180.0 + (index * 30.0);
            return Container(
              width: radius,
              height: radius,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.onSurface.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            );
          }),
          // Spinning Effect Rings
          for (var i = 0; i < 3; i++) _buildAnimatedRing(i),
          // Timer Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_selectedMinutes',
                style: GoogleFonts.inter(
                  fontSize: 100,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface,
                  letterSpacing: -4,
                ),
              ),
              Text(
                'MINUTES',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedRing(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _pulseController.value * 2 * 3.14159 * (index == 1 ? -1 : 1),
          child: Container(
            width: 220 + (index * 40),
            height: 220 + (index * 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.chronosPurple.withValues(alpha: 0.1 - (index * 0.03)),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.chronosPurpleGlow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProtocolCard() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1F), // Dark container for icon
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: const Icon(Icons.shield_rounded, color: AppColors.chronosPurpleGlow, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STRICT PROTOCOL',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Locks vault during session',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isStrict,
            onChanged: (v) async {
              if (v) {
                final hasAccess = await _lockService.hasDndAccess();
                if (!hasAccess) {
                  await _showPermissionDialog();
                  return;
                }
              }
              setState(() => _isStrict = v);
            },
            activeTrackColor: AppColors.chronosPurpleGlow,
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [15, 25, 45, 60].map((mins) {
        final isSelected = _selectedMinutes == mins;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedMinutes = mins);
          },
          child: SizedBox(
            width: 72,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: 16,
              opacity: isSelected ? 0.2 : 0.05,
              child: Column(
                children: [
                  Text(
                    '$mins',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? AppColors.chronosPurpleGlow : AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'MIN',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: isSelected ? AppColors.chronosPurpleGlow.withValues(alpha: 0.5) : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.chronosPurple.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          await _focusService.startSession(Duration(minutes: _selectedMinutes), _isStrict);
          _navigateToActiveFocus();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.chronosPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'IGNITE FLOW',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
