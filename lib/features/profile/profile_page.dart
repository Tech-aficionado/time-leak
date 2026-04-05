import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/auth_service.dart';
import '../../services/usage_tracking_service.dart';
import '../../services/local_storage_service.dart';
import 'focus_tuning_page.dart';
import 'appearance_matrix_page.dart';
import 'privacy_permissions_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  final AuthService _authService = AuthService();
  final UsageTrackingService _usageService = UsageTrackingService();
  final LocalStorageService _storageService = LocalStorageService();
  
  Map<String, dynamic>? _careerStats;
  bool _isLoading = true;
  bool _hasInitialLoad = false;
  StreamSubscription<DateTime>? _refreshSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Subscribe to global refresh ticks — updates profile on every data cycle
    _refreshSubscription = _usageService.refreshTick.listen((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_hasInitialLoad) {
      setState(() => _isLoading = true);
    }
    
    try {
      final stats = await _usageService.getCareerStats();
      if (mounted) {
        // Deep comparison to prevent flickering
        // We only trigger a rebuild if significant metrics change (rounded to minutes)
        final bool hasChanged = _careerStats == null || 
            _careerStats!['systemRank'] != stats['systemRank'] ||
            (_careerStats!['totalTime'] as Duration).inMinutes != (stats['totalTime'] as Duration).inMinutes ||
            (_careerStats!['totalLeaks'] as Duration).inMinutes != (stats['totalLeaks'] as Duration).inMinutes ||
            _careerStats!['efficiency'] != stats['efficiency'] ||
            _careerStats!['successfulFocusSessions'] != stats['successfulFocusSessions'];

        if (hasChanged || (_isLoading && !_hasInitialLoad)) {
          setState(() {
            _careerStats = stats;
            _isLoading = false;
            _hasInitialLoad = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.chronosPurpleGlow,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserProfile(context, user)
                        .animate(autoPlay: !_hasInitialLoad)
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.1, end: 0, curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    
                    if (_isLoading && !_hasInitialLoad)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: AppColors.chronosPurpleGlow),
                        ),
                      )
                    else ...[
                      _buildNeuroMetricsSection()
                          .animate(autoPlay: !_hasInitialLoad, delay: !_hasInitialLoad ? 200.ms : Duration.zero)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      _buildSecuritySection()
                          .animate(autoPlay: !_hasInitialLoad, delay: !_hasInitialLoad ? 400.ms : Duration.zero)
                          .fadeIn(duration: 600.ms),
                      const SizedBox(height: 24),
                      _buildSettingsSection()
                          .animate(autoPlay: !_hasInitialLoad, delay: !_hasInitialLoad ? 600.ms : Duration.zero)
                          .fadeIn(duration: 600.ms),
                      const SizedBox(height: 48),
                      _buildLogoutButton(context)
                          .animate(autoPlay: !_hasInitialLoad, delay: !_hasInitialLoad ? 800.ms : Duration.zero)
                          .fadeIn(),
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
              'COMMAND PROFILE',
              style: GoogleFonts.inter(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'NEURAL SYNC: ${_isLoading ? "SYNCHRONIZING..." : "ONLINE"}',
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

  Widget _buildUserProfile(BuildContext context, User? user) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.chronosPurpleGlow.withValues(alpha: 0.2), width: 1),
                ),
              ).animate(onPlay: (controller) => controller.repeat()).rotate(duration: 8.seconds),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.surfaceContainerHighest,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null 
                  ? const Icon(Icons.person, color: AppColors.chronosPurpleGlow, size: 40)
                  : null,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName?.toUpperCase() ?? 'IDENTIFYING...',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _careerStats?['systemRank'] ?? 'COMMANDER',
                  style: GoogleFonts.inter(
                    color: AppColors.chronosPurpleGlow,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildNeuroMetricsSection() {
    final stats = _careerStats;
    
    if (stats == null) {
      return _buildNoStatsPlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NEURAL PERFORMANCE',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatMiniCard(
                'TIME SAVED',
                _formatDuration(stats['totalTime'] - stats['totalLeaks']),
                Icons.hourglass_empty,
                AppColors.chronosPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatMiniCard(
                'FOCUS POWER',
                '${(stats['efficiency'] * 100).toStringAsFixed(1)}%',
                Icons.bolt,
                AppColors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildMetricLine('Total Unlocks Countered', stats['totalUnlocks'].toString()),
              const Divider(color: Colors.white10),
              _buildMetricLine('Successful Focus Runs', stats['successfulFocusSessions'].toString()),
              const Divider(color: Colors.white10),
              _buildMetricLine('Deep Work Acquired', _formatDuration(stats['totalFocusTime'])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatMiniCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            color: AppColors.chronosPurpleGlow,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VAULT STATUS',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSecurityTile(
                'ISAR ENCRYPTION',
                _storageService.isEncrypted ? 'ACTIVE - SECURE STORE' : 'STANDBY - LOCAL CACHE',
                _storageService.isEncrypted ? Icons.lock : Icons.lock_open_outlined,
                _storageService.isEncrypted ? AppColors.chronosPurple : AppColors.onSurfaceVariant,
              ),
              const Divider(color: Colors.white10),
              _buildSecurityTile(
                'CLOUD SYNC',
                _authService.isSupabaseSyncActive ? 'COHESION ACTIVE' : 'LOCAL ONLY',
                _authService.isSupabaseSyncActive ? Icons.cloud_done : Icons.cloud_off_outlined,
                _authService.isSupabaseSyncActive ? AppColors.chronosPurple : AppColors.onSurfaceVariant,
              ),
              const Divider(color: Colors.white10),
              _buildSecurityTile(
                'NEURAL IDENTITY',
                'PROTECTED',
                Icons.verified_user_outlined,
                AppColors.chronosPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTile(String title, String status, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
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
                    fontSize: 13,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APPARATUS SETTINGS',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _buildSettingsTile(
                'Focus Mode Tuning', 
                Icons.settings_input_component_outlined,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FocusTuningPage())),
              ),
              _buildSettingsTile(
                'Appearance Matrix', 
                Icons.palette_outlined,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AppearanceMatrixPage())),
              ),
              _buildSettingsTile(
                'Privacy & Permissions', 
                Icons.shield_outlined,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PrivacyPermissionsPage())),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.onSurfaceVariant, size: 12),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 12,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            foregroundColor: Colors.redAccent.withValues(alpha: 0.8),
          ),
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text(
            'DEAUTHORIZE COMMAND',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Security Check', style: GoogleFonts.inter(color: AppColors.onSurface)),
        content: const Text('Deauthorize this system identity? All local command cache will remain secured.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ABORT', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DEAUTHORIZE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      // The authStateChanges stream in main.dart will automatically handle navigation back to LandingPage
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m';
    }
    return '0m';
  }

  Widget _buildNoStatsPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.chronosPurpleGlow.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.query_stats, color: AppColors.chronosPurpleGlow.withValues(alpha: 0.4), size: 48),
          const SizedBox(height: 16),
          Text(
            'SYNCHRONIZING CAREER NEXUS',
            style: GoogleFonts.outfit(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your lifetime metrics are being aggregated from the distributed nodes. This may take a moment on fresh installations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
