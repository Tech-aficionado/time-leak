import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppearanceMatrixPage extends StatefulWidget {
  const AppearanceMatrixPage({super.key});

  @override
  State<AppearanceMatrixPage> createState() => _AppearanceMatrixPageState();
}

class _AppearanceMatrixPageState extends State<AppearanceMatrixPage> {
  Color _selectedAccent = AppColors.chronosPurpleGlow;
  double _glassOpacity = 0.4;

  final List<Color> _accents = [
    AppColors.chronosPurpleGlow,
    const Color(0xFF00E5FF), // Cyber Cyan
    const Color(0xFFFF9D00), // Neural Amber
    const Color(0xFF00FFA1), // Bio Green
    const Color(0xFFFF2D55), // Logic Red
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('APPEARANCE MATRIX'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('NEURAL CALIBRATION'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [AppColors.surfaceContainer, _selectedAccent.withValues(alpha: 0.3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: _selectedAccent.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: _selectedAccent.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: -10),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.auto_awesome, color: _selectedAccent, size: 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _accents.map((color) => _buildAccentButton(color)).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('UI DENSITY & OPACITY'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Glassmorphism Strength', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Slider(
                    value: _glassOpacity,
                    min: 0.1,
                    max: 0.9,
                    onChanged: (v) => setState(() => _glassOpacity = v),
                    activeColor: _selectedAccent,
                    inactiveColor: Colors.white10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transparent', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      Text('Solid', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('COMMAND CENTER UI'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: SwitchListTile(
                title: const Text('Show Neural Pulse Animation', style: TextStyle(color: AppColors.onSurface, fontSize: 14)),
                value: true,
                onChanged: (v) {},
                activeColor: _selectedAccent,
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'CHRONOS OS V1.0.4 - EMERALD EDITION',
                style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4), fontSize: 10, letterSpacing: 1.0),
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
      style: TextStyle(
        color: _selectedAccent,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildAccentButton(Color color) {
    final isSelected = _selectedAccent == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedAccent = color),
      child: AnimatedContainer(
        duration: 300.ms,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 3),
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
