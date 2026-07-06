import 'package:flutter/material.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/presentation/pages/edit_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/settings_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/profile_card_body.dart';
import 'package:hourlink/features/auth/presentation/widgets/profile_screen_shell.dart';
import 'package:hourlink/features/auth/data/services/user_service.dart';

class MyProfileScreen extends StatefulWidget {
  final AppUser? user;

  const MyProfileScreen({super.key, this.user});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final UserService _userService = UserService();
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    // Show passed-in user immediately while stream loads
    if (widget.user != null) {
      _user = widget.user;
    }
    // Always subscribe to live Firestore updates
    _userService.getCurrentUserStream().listen((currentUser) {
      if (mounted && currentUser != null) {
        setState(() => _user = currentUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ProfileScreenShell(
      headerRightIcon: Icons.settings_outlined,
      avatarUrl: _user!.photoUrl, // ← ajouté
      avatarName: _user!.name,
      onHeaderRightTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SettingsScreen(user: _user!)),
        );
      },
      body: ProfileCardBody(
        user: _user!,
        topRightIcon: Icons.edit_outlined,
        onTopRightTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
          );
        },
      ),
    );
  }
}
