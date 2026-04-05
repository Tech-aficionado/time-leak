import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/usage_tracking_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  late final UsageTrackingService _trackingService;
  bool _hasInitialLoad = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _trackingService = UsageTrackingService();
    // Force a data refresh when we enter the page
    _trackingService.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return StreamBuilder<HomeMetrics>(
      stream: _trackingService.metricsStream,
      initialData: _trackingService.lastMetrics,
      builder: (context, snapshot) {
        final metrics = snapshot.data;
        
        // If we have metrics, and we haven't marked initial load yet, do it now.
        if (!_hasInitialLoad && metrics != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _hasInitialLoad = true);
          });
        }

        final bool isFirstAppearance = !_hasInitialLoad && metrics != null;
        final bool isDataEmpty = metrics != null && metrics.totalScreenTime.inSeconds == 0 && metrics.appSwitches == 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: (metrics == null && !_hasInitialLoad)
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.chronosPurpleGlow),
                )
              : RefreshIndicator(
                  color: AppColors.chronosPurpleGlow,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  onRefresh: () => _trackingService.refreshData(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      _buildSliverAppBar(context),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isDataEmpty)
                                _buildNoDataPlaceholder()
                                    .animate(autoPlay: !_hasInitialLoad)
                                    .fadeIn(duration: 600.ms)
                              else ...[
                                _buildFocusScoreHeader(metrics?.focusScore ?? 0.0)
                                    .animate(autoPlay: !_hasInitialLoad)
                                    .fadeIn(duration: 600.ms)
                                    .slideX(begin: -0.1, end: 0, curve: Curves.easeOutBack),
                                const SizedBox(height: 24),
                                _buildStatGrid(metrics)
                                    .animate(autoPlay: !_hasInitialLoad, delay: !_hasInitialLoad ? 200.ms : Duration.zero)
                                    .fadeIn(duration: 600.ms)
                                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
                                const SizedBox(height: 24),
                                _buildActiveAlerts(metrics)
                                    .animate(autoPlay: !_hasInitialLoad, delay: !_hasInitialLoad ? 400.ms : Duration.zero)
                                    .fadeIn(duration: 600.ms),
                                const SizedBox(height: 24),
                                _buildUsageChartPlaceholder(metrics)
                                    .animate(autoPlay: !_hasInitialLoad, delay: !_hasInitialLoad ? 600.ms : Duration.zero)
                                    .fadeIn(duration: 600.ms)
                                    .scale(begin: const Offset(0.95, 0.95)),
                              ],
                              const SizedBox(height: 120), // Padding for FloatingNavBar
                            ],
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


  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHRONOS COMMAND',
              style: GoogleFonts.inter(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'COMMAND_OPERATIONS_ACTIVE',
              style: GoogleFonts.inter(
                color: AppColors.chronosPurpleGlow,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusScoreHeader(double score) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEURAL FOCUS SCORE',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        color: AppColors.onSurface,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2.0,
                      ),
                    ),
                    Text(
                      '%',
                      style: GoogleFonts.inter(
                        color: AppColors.chronosPurpleGlow,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.chronosPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.chronosPurple.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'OPTIMAL STABILITY',
                    style: GoogleFonts.inter(
                      color: AppColors.chronosPurpleGlow,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCircularProgress(score),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double score) {
    final progress = score / 100.0;
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.chronosPurpleGlow.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Progress Background
          const SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 2,
              color: AppColors.surfaceContainerHighest,
            ),
          ),
          // Actual Progress
          SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: AppColors.chronosPurpleGlow,
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                  duration: 2.seconds,
                  color: Colors.white24,
                ),
          ),
          // Core Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.chronosPurple.withValues(alpha: 0.3), width: 1),
            ),
            child: const Icon(Icons.bolt, color: AppColors.chronosPurpleGlow, size: 28),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 1.seconds,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(HomeMetrics? metrics) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('SCREEN TIME', _formatDuration(metrics?.totalScreenTime ?? Duration.zero), Icons.visibility_outlined),
        _buildStatCard('LEAKED TIME', '${metrics?.microLeaks ?? 0}m', Icons.warning_amber_outlined),
        _buildStatCard('APP SWITCHES', '${metrics?.appSwitches ?? 0}', Icons.refresh),
        _buildStatCard('UNLOCKS', '${metrics?.unlockFrequency ?? 0}', Icons.lock_open_outlined),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, size: 14, color: AppColors.chronosPurpleGlow.withValues(alpha: 0.7)),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlerts(HomeMetrics? metrics) {
    final vortexes = metrics?.vortexes ?? [];
    if (vortexes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VORTEX ALERTS',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        ...vortexes.map((v) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildAlertItem(
            'Digital Vortex Detected',
            'Chain: ${v.appChain.take(3).join(" -> ")} ... (${v.totalDuration.inMinutes}m)',
            Icons.emergency_outlined,
            v.intensity == 'Critical' ? Colors.redAccent : Colors.orangeAccent,
          ),
        )),
      ],
    );
  }

  Widget _buildAlertItem(String title, String subtitle, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChartPlaceholder(HomeMetrics? metrics) {
    final flowPoints = metrics?.flowPoints ?? [];
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEURAL INTENSITY / SYSTEM LOAD',
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(Icons.show_chart, color: AppColors.chronosPurpleGlow, size: 16),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        if (value % 4 == 0) {
                          final h = value.toInt();
                          return Text('${h.toString().padLeft(2, '0')}:00', style: style);
                        }
                        return const Text('', style: style);
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 24,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: flowPoints.isEmpty 
                      ? [const FlSpot(0, 3), const FlSpot(24, 3)]
                      : flowPoints.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble() * (24 / flowPoints.length), e.value.riskLevel.toDouble() + 1);
                        }).toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.chronosPurple, AppColors.chronosPurpleGlow],
                      stops: [0.1, 1.0],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.chronosPurple.withValues(alpha: 0.2),
                          AppColors.chronosPurple.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataPlaceholder() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.radar, size: 48, color: AppColors.chronosPurpleGlow),
          const SizedBox(height: 16),
          Text(
            'NO NEURAL DATA DETECTED',
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CHRONOS Command is active and monitoring. Usage stats will appear here as soon as they are processed by the system.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            backgroundColor: AppColors.surfaceContainerHigh,
            color: AppColors.chronosPurpleGlow.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
