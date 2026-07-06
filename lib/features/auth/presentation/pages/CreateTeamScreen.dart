// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/services/team_service.dart';
import 'package:hourlink/features/auth/data/services/user_service.dart';
import 'package:hourlink/features/auth/presentation/widgets/app_text_field.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';
import 'package:image_picker/image_picker.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _teamService = TeamService();
  final _userService = UserService();

  File? _pickedImage;
  bool _isSubmitting = false;
  bool _isSearching = false;
  List<AppUser> _searchResults = [];
  List<AppUser> _selectedMembers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await _userService.searchUsers(query);
    if (mounted) {
      setState(() {
        _searchResults = results
            .where((u) => !_selectedMembers.any((m) => m.id == u.id))
            .toList();
        _isSearching = false;
      });
    }
  }

  void _addMember(AppUser user) {
    setState(() {
      _selectedMembers.add(user);
      _searchResults.remove(user);
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _removeMember(AppUser user) {
    setState(() => _selectedMembers.remove(user));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final team = await _teamService.createTeam(
        name: _nameController.text.trim(),
        bio: _descController.text.trim(),
      );

      // Add selected members
      for (final member in _selectedMembers) {
        await _teamService.addMember(teamId: team.id, userId: member.id);
      }

      if (!mounted) return;

      SuccessDialog.show(
        context,
        title: 'Team Created!',
        message:
            'Your team "${_nameController.text.trim()}" has been created successfully.',
        buttonLabel: 'Done',
        onDone: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context, true); // return true → triggers refresh
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create team: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompact = width < 360;
            final isWide = width >= 600;
            final horizontalPadding = isCompact
                ? 18.0
                : isWide
                ? 48.0
                : 30.0;
            final avatarSize = isCompact
                ? 90.0
                : isWide
                ? 130.0
                : 110.0;
            final titleFontSize = isCompact ? 16.0 : 18.0;
            final maxContentWidth = isWide ? 560.0 : double.infinity;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isCompact ? 24 : 40),

                        // ── Top bar ───────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: AppColors.textDark,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: Text(
                                  'Create a New Team',
                                  style: AppTextStyles.subheading.copyWith(
                                    fontSize: titleFontSize,
                                  ),
                                ),
                              ),
                              _isSubmitting
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: _submit,
                                    ),
                            ],
                          ),
                        ),

                        SizedBox(height: isCompact ? 16 : 24),

                        // ── Avatar picker ─────────────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.textDark,
                                  width: 0.5,
                                ),
                                image: _pickedImage != null
                                    ? DecorationImage(
                                        image: FileImage(_pickedImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _pickedImage == null
                                  ? Icon(
                                      Icons.camera_alt_outlined,
                                      size: avatarSize * 0.32,
                                      color: AppColors.textGrey,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            _pickedImage == null
                                ? 'Add a team picture'
                                : 'Tap to change picture',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: isCompact ? 13 : 14,
                            ),
                          ),
                        ),

                        SizedBox(height: isCompact ? 24 : 32),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Team name ─────────────────────────────
                              Text(
                                'Team Name :',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppTextField(
                                controller: _nameController,
                                hint: 'team name',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Team name is required';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // ── Team description ──────────────────────
                              Text(
                                'Team Description :',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppTextField(
                                controller: _descController,
                                hint: 'team is about ….',
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Description is required';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // ── Add members ───────────────────────────
                              Text(
                                'Add Team Members :',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Selected members chips
                              if (_selectedMembers.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _selectedMembers.map((member) {
                                    return Chip(
                                      avatar: CircleAvatar(
                                        backgroundImage:
                                            member.photoUrl.isNotEmpty
                                            ? NetworkImage(member.photoUrl)
                                            : null,
                                        child: member.photoUrl.isEmpty
                                            ? Text(member.name[0].toUpperCase())
                                            : null,
                                      ),
                                      label: Text(member.name),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 16,
                                      ),
                                      onDeleted: () => _removeMember(member),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Search field
                              AppTextField(
                                controller: _searchController,
                                hint: 'Search by name…',
                                onChanged: _searchUsers,
                              ),

                              // Search results
                              if (_isSearching)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              else if (_searchResults.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.textGrey.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final user = _searchResults[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              user.photoUrl.isNotEmpty
                                              ? NetworkImage(user.photoUrl)
                                              : null,
                                          child: user.photoUrl.isEmpty
                                              ? Text(user.name[0].toUpperCase())
                                              : null,
                                        ),
                                        title: Text(user.name),
                                        subtitle: Text(user.email),
                                        onTap: () => _addMember(user),
                                      );
                                    },
                                  ),
                                ),

                              SizedBox(height: isCompact ? 28 : 40),

                              // ── Clear button ───────────────────────────
                              Center(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: AppColors.textGrey,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    _nameController.clear();
                                    _descController.clear();
                                    _searchController.clear();
                                    setState(() {
                                      _pickedImage = null;
                                      _selectedMembers = [];
                                      _searchResults = [];
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
