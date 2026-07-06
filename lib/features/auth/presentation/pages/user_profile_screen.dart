import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/services/chat_service.dart';
import 'package:hourlink/features/auth/data/services/team_service.dart';
import 'package:hourlink/features/auth/presentation/pages/add_to_team_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/chat_room_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/profile_card_body.dart';
import 'package:hourlink/features/auth/presentation/widgets/profile_screen_shell.dart';

class UserProfileScreen extends StatefulWidget {
  final AppUser user;
  final String currentUserId;

  const UserProfileScreen({
    super.key,
    required this.user,
    required this.currentUserId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ChatService _chatService = ChatService();
  final TeamService _teamService = TeamService();

  List<Team> _myTeams = [];
  bool _loadingTeams = true;
  bool _openingChat = false;

  @override
  void initState() {
    super.initState();
    _loadMyTeams();
  }

  // Charger les teams dont l'utilisateur courant est owner
  // pour pouvoir y ajouter quelqu'un
  Future<void> _loadMyTeams() async {
    try {
      final teams = await _teamService.getMyTeams();
      if (mounted) setState(() => _myTeams = teams);
    } catch (e) {
      debugPrint('Error loading teams: $e');
    } finally {
      if (mounted) setState(() => _loadingTeams = false);
    }
  }

  Future<void> _openChat() async {
    if (_openingChat) return;
    setState(() => _openingChat = true);

    try {
      final chat = await _chatService.getOrCreateDirectChat(widget.user);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChatRoomScreen(chat: chat, currentUserId: widget.currentUserId),
        ),
      );
    } catch (e) {
      debugPrint('Error opening chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
      }
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScreenShell(
      headerRightIcon: Icons.add,
      avatarUrl: widget.user.photoUrl, // ← ajouté
      avatarName: widget.user.name,
      onHeaderRightTap: () {
        if (_loadingTeams) return; // ignorer le tap pendant le chargement
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AddToTeamScreen(user: widget.user, allTeams: _myTeams),
          ),
        );
      },
      body: ProfileCardBody(
        user: widget.user,
        topRightIcon: _openingChat
            ? Icons.hourglass_empty
            : Icons.chat_bubble_outline_rounded,
        onTopRightTap: _openingChat ? null : _openChat,
      ),
    );
  }
}
