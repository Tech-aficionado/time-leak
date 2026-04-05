import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPermissionsPage extends StatelessWidget {
  const PrivacyPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PRIVACY & PERMISSIONS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('SYSTEM ACCESS'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                   _buildPermissionTile(
                    'App Usage Access',
                    'Required for Neural Hygiene reports.',
                    Icons.insights_outlined,
                    true,
                    () {},
                  ),
                  const Divider(color: Colors.white10),
                   _buildPermissionTile(
                    'System Overlay',
                    'Enables the Neural Lock screen.',
                    Icons.layers_outlined,
                    true,
                    () {},
                  ),
                  const Divider(color: Colors.white10),
                   _buildPermissionTile(
                    'Critical Alerts',
                    'Notifications for focus intrusions.',
                    Icons.notifications_active_outlined,
                    false,
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('DATA MANAGEMENT'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   _buildActionTile(
                    'Export Local Cache',
                    'Download all session data in JSON format.',
                    Icons.download_rounded,
                    () {},
                  ),
                   const Divider(color: Colors.white10),
                   _buildActionTile(
                    'Purge System Data',
                    'Irreversibly delete all local records.',
                    Icons.delete_forever,
                    () {},
                    isDanger: true,
                  ),
                ],
              ),
            ),
             const SizedBox(height: 32),
             _buildSectionHeader('CORE PRIVACY'),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.security, color: AppColors.chronosPurpleGlow, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'End-to-End Encryption Enabled',
                    style: GoogleFonts.inter(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your digital habits are processed locally and only synced as encrypted binary streams. No readable usage data is shared with third parties.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
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

  Widget _buildPermissionTile(String title, String subtitle, IconData icon, bool isActive, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
      title: Text(title, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? Colors.green.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.2), width: 1),
        ),
        child: Text(
          isActive ? 'ACTIVE' : 'LOCKED',
          style: TextStyle(color: isActive ? Colors.greenAccent : Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDanger = false}) {
     return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.redAccent : AppColors.onSurfaceVariant, size: 20),
      title: Text(title, style: TextStyle(color: isDanger ? Colors.redAccent : AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
      onTap: onTap,
    );
  }
}
