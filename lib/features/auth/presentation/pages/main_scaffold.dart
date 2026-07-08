import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/presentation/pages/Dashboard_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/chats_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/my_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/teams_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/bottom_nav_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late List<Widget> _pages; // 👈 late — built once in initState

  AppUser get _currentAppUser {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return AppUser(
      id: firebaseUser?.uid ?? '',
      name: firebaseUser?.displayName ?? '',
      email: firebaseUser?.email ?? '',
      photoUrl: firebaseUser?.photoURL ?? '',
    );
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );

    // 👈 build pages ONCE — never rebuilt on nav taps
    final user = _currentAppUser;
    _pages = [
      MyDashboard(currentUser: user),
      MyTeamsScreen(currentUser: user),
      ChatsScreen(currentUserId: user.id),
      MyProfileScreen(user: user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 👈 keeps all pages alive — only visibility changes on tap
          IndexedStack(index: _currentIndex, children: _pages),

          // ── Floating bottom nav ───────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}
