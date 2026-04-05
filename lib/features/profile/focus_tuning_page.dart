import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

class FocusTuningPage extends StatefulWidget {
  const FocusTuningPage({super.key});

  @override
  State<FocusTuningPage> createState() => _FocusTuningPageState();
}

class _FocusTuningPageState extends State<FocusTuningPage> {
  double _sessionDuration = 25;
  double _breakDuration = 5;
  bool _strictModeDefault = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FOCUS TUNING'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('TEMPORAL RULES'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSliderTile(
                    'Work Session',
                    '${_sessionDuration.toInt()} Minutes',
                    _sessionDuration,
                    1,
                    60,
                    (v) => setState(() => _sessionDuration = v),
                    Icons.timer_outlined,
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  _buildSliderTile(
                    'Neural Break',
                    '${_breakDuration.toInt()} Minutes',
                    _breakDuration,
                    1,
                    30,
                    (v) => setState(() => _breakDuration = v),
                    Icons.coffee_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('ENFORCEMENT MODE'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SwitchListTile(
                title: const Text('Strict Neural Lock', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Blocks all apps and system gestures during session.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                value: _strictModeDefault,
                onChanged: (v) => setState(() => _strictModeDefault = v),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('WHITELISTS'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.app_registration_outlined, color: AppColors.onSurfaceVariant, size: 40),
                    const SizedBox(height: 16),
                    const Text(
                      'App Shield Active',
                      style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All secondary apps are filtered. Custom whitelist coming in V2.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.chronosPurpleGlow,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildSliderTile(String label, String value, double currentValue, double min, double max, ValueChanged<double> onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 18),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            Text(value, style: GoogleFonts.jetBrainsMono(color: AppColors.chronosPurpleGlow, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: currentValue,
          min: min,
          max: max,
          onChanged: onChanged,
          inactiveColor: Colors.white10,
        ),
      ],
    );
  }
}
