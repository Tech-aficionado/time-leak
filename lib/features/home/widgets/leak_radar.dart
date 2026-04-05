import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LeakRadar extends StatelessWidget {
  final List<double> heatmapList;
  final String title;

  const LeakRadar({
    super.key,
    required this.heatmapList,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // heatmapList is expected to be 24 values (hourly)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildHeatmapGrid(),
      ],
    );
  }

  Widget _buildHeatmapGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 4.0;
        final double size = (constraints.maxWidth - (11 * spacing)) / 12;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(24, (index) {
            final intensity = index < heatmapList.length ? heatmapList[index] : 0.0;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: _getIntensityColor(intensity),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: intensity > 0.5 ? AppColors.chronosPurpleGlow.withValues(alpha: 0.3) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: intensity > 0.6 ? Colors.black54 : Colors.white24,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Color _getIntensityColor(double intensity) {
    if (intensity <= 0) return AppColors.surfaceContainerHighest.withValues(alpha: 0.2);
    return AppColors.chronosPurple.withValues(alpha: 0.1 + (intensity * 0.9));
  }
}
