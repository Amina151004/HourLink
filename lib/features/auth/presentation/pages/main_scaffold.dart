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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  // ── Convert Firebase User → your AppUser model ────────────────────────
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
  Widget build(BuildContext context) {
    // ── Build pages here so _currentAppUser is accessible ─────────────
    final List<Widget> pages = [
      MyDashboard(currentUser: _currentAppUser),
      MyTeamsScreen(currentUser: _currentAppUser),
      ChatsScreen(currentUserId: _currentAppUser.id),
      MyProfileScreen(user: _currentAppUser),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Active page ───────────────────────────────────────────────
          pages[_currentIndex],

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
