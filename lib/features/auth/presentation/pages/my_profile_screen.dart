import 'package:flutter/material.dart';
import 'package:hourlink/features/auth/data/models/user.dart';
import 'package:hourlink/features/auth/presentation/widgets/profile_card_body.dart';
import 'package:hourlink/features/auth/presentation/widgets/profile_screen_shell.dart';

/// Viewing your OWN profile — header action is "settings",
/// card top-right action is "edit profile".
class MyProfileScreen extends StatelessWidget {
  final User user;

  const MyProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ProfileScreenShell(
      headerRightIcon: Icons.settings_outlined,
      onHeaderRightTap: () {},
      body: ProfileCardBody(
        user: user,
        topRightIcon: Icons.edit_outlined,
        onTopRightTap: () {},
      ),
    );
  }
}
