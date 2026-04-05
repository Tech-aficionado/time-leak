import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/usage_tracking_service.dart';
import '../../models/session.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'widgets/deep_analysis_widgets.dart';
import '../home/widgets/leak_radar.dart';

class AppDetailsPage extends StatefulWidget {
  final UsageAppInfo appInfo;

  const AppDetailsPage({super.key, required this.appInfo});

  @override
  State<AppDetailsPage> createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage> {
  final UsageTrackingService _service = UsageTrackingService();
  late Future<(List<Session>, AppDeepMetrics)> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<(List<Session>, AppDeepMetrics)> _fetchData() async {
    final results = await Future.wait([
      _service.getSessionsForApp(widget.appInfo.packageName),
      _service.getAppDeepMetrics(widget.appInfo.packageName),
    ]);
    return (results[0] as List<Session>, results[1] as AppDeepMetrics);
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  String _formatTime(DateTime time) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<(List<Session>, AppDeepMetrics)>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.chronosPurpleGlow));
          }

          if (snapshot.hasError) {
            return Center(child: Text('TELEMETRY FAILURE', style: GoogleFonts.manrope(color: AppColors.error)));
          }

          final sessions = snapshot.data?.$1 ?? [];
          final deepMetrics = snapshot.data?.$2;
          sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
          final microLeaksCount = sessions.where((s) => s.isMicroLeak).length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Immersive App Bar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    widget.appInfo.appName.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop Glow
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.chronosPurpleGlow.withValues(alpha: 0.05),
                              AppColors.background,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Large Icon
                      Positioned(
                        bottom: 60,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: widget.appInfo.iconBytes != null
                                  ? Image.memory(widget.appInfo.iconBytes!, fit: BoxFit.cover)
                                  : const Icon(Icons.android_rounded, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 12),
                    // Core Stats Bento
                    _buildCoreStats(sessions.length, microLeaksCount, deepMetrics)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 32),
                    
                    // Deep Visuals
                    if (deepMetrics != null) ...[
                      _buildTelemetrySection('TEMPORAL DENSITY', 'Usage intensity distribution')
                          .animate()
                          .fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: LeakRadar(
                          heatmapList: deepMetrics.hourlyUsage.map((e) => e.toDouble()).toList(),
                          title: '', 
                        ),
                      ).animate()
                        .fadeIn(delay: 300.ms)
                        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
                      const SizedBox(height: 32),
                      _buildChainAnalysis(deepMetrics)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                    ],

                    const SizedBox(height: 32),
                    _buildTelemetrySection('SESSION LOGS', 'Historical session telemetry')
                        .animate()
                        .fadeIn(delay: 500.ms),
                    const SizedBox(height: 16),
                    
                    if (sessions.isEmpty)
                      Center(child: Text('NO RECENT ACTIVITY', style: GoogleFonts.inter(color: Colors.white24)))
                    else
                      ...sessions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final s = entry.value;
                        return _buildSessionLog(s)
                            .animate(delay: (600 + (index * 50)).ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.05, end: 0);
                      }),
                    
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTelemetrySection(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildCoreStats(int sessions, int leaks, AppDeepMetrics? metrics) {
    return Column(
      children: [
        if (metrics != null)
           Padding(
             padding: const EdgeInsets.only(bottom: 24),
             child: GlassCard(
               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
               child: AppLeakGauge(leakFactor: metrics.leakFactor),
             ),
           ),
        Row(
          children: [
            Expanded(
              child: _buildStatPod('TOTAL TIME', _formatDuration(widget.appInfo.usageDuration), AppColors.chronosPurpleGlow),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatPod('SESSIONS', '$sessions', Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatPod(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainAnalysis(AppDeepMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: AppChainCard(
            title: 'TRIGGER OPS',
            apps: metrics.triggerApps.keys.toList(),
            icon: Icons.login_rounded,
            color: const Color(0xFFFBBF24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppChainCard(
            title: 'FOLLOW-UP',
            apps: metrics.followUpApps.keys.toList(),
            icon: Icons.logout_rounded,
            color: const Color(0xFFA78BFA),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionLog(Session session) {
    final bool isLeak = session.isMicroLeak;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        opacity: isLeak ? 0.1 : 0.05,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: isLeak ? AppColors.error : AppColors.chronosPurpleGlow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatTime(session.startTime)} — ${_formatTime(session.endTime)}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (isLeak)
                    Text(
                      'ANOMALY: MICRO-LEAK DETECTED',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.error.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              _formatDuration(session.duration),
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isLeak ? AppColors.error : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
