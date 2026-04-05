import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/usage_tracking_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'app_details_page.dart';

class UsageLeaderboardPage extends StatefulWidget {
  const UsageLeaderboardPage({super.key});

  @override
  State<UsageLeaderboardPage> createState() => _UsageLeaderboardPageState();
}

class _UsageLeaderboardPageState extends State<UsageLeaderboardPage> {
  final UsageTrackingService _service = UsageTrackingService();
  bool _hasInitialLoad = false;

  @override
  void initState() {
    super.initState();
    // Global auto-refresh (started in main.dart) keeps the stream live.
    // Trigger an immediate refresh in case the page is opened cold.
    _service.refreshData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header
          SliverAppBar(
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
                    'LEAK REGISTRY',
                    style: GoogleFonts.inter(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Active Threat Monitoring',
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
          ),

          StreamBuilder<List<UsageAppInfo>>(
            stream: _service.usageStream,
            initialData: _service.lastUsage,
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];
              final bool isFirstAppearance = !_hasInitialLoad && data.isNotEmpty;

              if (isFirstAppearance) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _hasInitialLoad = true);
                });
              }
              
              if (snapshot.connectionState == ConnectionState.waiting && data.isEmpty && !_hasInitialLoad) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.chronosPurpleGlow)),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('TELEMETRY ERROR: ${snapshot.error}', style: const TextStyle(color: AppColors.error))),
                );
              }

              if (data.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'ZERO LEAKS DETECTED',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              }

              final totalUsage = data.fold<double>(
                0,
                (sum, item) => sum + item.usageMinutes,
              );

              return SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final app = data[index];
                      final rank = index + 1;
                      final percentage = totalUsage > 0 ? (app.usageMinutes / totalUsage) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _LeaderboardEntry(
                          rank: rank,
                          app: app,
                          percentage: percentage,
                        )
                            .animate(autoPlay: isFirstAppearance, delay: isFirstAppearance ? (index * 50).ms : Duration.zero)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.1, end: 0, curve: Curves.easeOut),
                      );
                    },
                    childCount: data.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final int rank;
  final UsageAppInfo app;
  final double percentage;

  const _LeaderboardEntry({
    required this.rank,
    required this.app,
    required this.percentage,
  });

  Color _getRankColor() {
    if (rank == 1) return const Color(0xFFFBBF24); // Gold/Amber
    if (rank == 2) return const Color(0xFFA78BFA); // Purple/Violet
    if (rank == 3) return AppColors.chronosPurpleGlow;
    return AppColors.outline;
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppDetailsPage(appInfo: app),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // High-Impact Rank Pod
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getRankColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _getRankColor().withValues(alpha: 0.3), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    rank.toString().padLeft(2, '0'),
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _getRankColor(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Optimized App Icon Tray
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: app.iconBytes != null
                      ? Image.memory(app.iconBytes!, fit: BoxFit.cover)
                      : const Icon(Icons.android_rounded, color: AppColors.onSurfaceVariant, size: 24),
                ),
              ),
              const SizedBox(width: 16),

              // Core Data Cluster
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            app.appName.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: AppColors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(app.usageDuration),
                          style: GoogleFonts.inter(
                            color: AppColors.chronosPurpleGlow,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Technical Progress Index
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getRankColor().withValues(alpha: 0.8),
                                  _getRankColor().withValues(alpha: 0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: _getRankColor().withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
