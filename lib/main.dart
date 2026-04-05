import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:timeleak/core/config/api_keys.dart';
import 'package:timeleak/features/onboarding/landing_page.dart';
import 'package:timeleak/features/onboarding/usage_permission_gate.dart';
import 'package:timeleak/services/auth_service.dart';
import 'package:timeleak/services/local_storage_service.dart';
import 'package:timeleak/services/focus_mode_service.dart';

import 'package:toastification/toastification.dart';

import 'package:timeleak/core/theme/app_theme.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: ApiKeys.supabaseUrl,
    anonKey: ApiKeys.supabaseAnonKey,
  );
  await LocalStorageService().init();
  await FocusModeService().init();

  // NOTE: UsageTrackingService().startAutoRefresh() is intentionally NOT called
  // here. The UsagePermissionGate will start the orchestrator only after the
  // PACKAGE_USAGE_STATS permission has been confirmed, preventing silent failures.
  
  // High-performance instrument feel: Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'Time Leak',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        home: StreamBuilder<User?>(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            // While we are checking if a user exists, show a localized placeholder
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.chronosPurpleGlow),
                ),
              );
            }
            
            // If the user has a valid session, skip login
            if (snapshot.hasData && snapshot.data != null) {
              return const UsagePermissionGate();
            }
            
            // Otherwise, show the landing page experience
            return const LandingPage();
          },
        ),
      ),
    );
  }
}
