import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/user.dart';
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

  final List<Widget> _pages = [
    const MyDashboard(),
    const MyTeamsScreen(),
    const ChatsScreen(),
    MyProfileScreen(
      user: User(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        title: '',
        location: '',
        description: '',
        id: '1',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ── Plus de bottomNavigationBar ici ───────────────────────────────
      body: Stack(
        children: [
          // ── Page active (prend tout l'écran) ──────────────────────────
          _pages[_currentIndex],

          // ── Navbar flottante en bas ────────────────────────────────────
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
