import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../insights/insights_page.dart';
import '../focus_mode/focus_mode_page.dart';
import '../usage_leaderboard/usage_leaderboard_page.dart';
import '../profile/profile_page.dart';

import 'widgets/floating_nav_bar.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const InsightsPage(),
    const FocusModePage(),
    const UsageLeaderboardPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
