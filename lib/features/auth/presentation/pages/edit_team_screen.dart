import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/services/team_service.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';
import 'package:hourlink/features/auth/data/services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';

class EditTeamScreen extends StatefulWidget {
  final Team team;

  const EditTeamScreen({super.key, required this.team});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  final TeamService _teamService = TeamService();
  final CloudinaryService _cloudinaryService = CloudinaryService(); // ✅ new

  File? _pickedImage;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _bioController = TextEditingController(text: widget.team.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
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

  Future<void> _saveTeam() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team name cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // ✅ Only upload if the user actually picked a new image;
      // otherwise pass null so updateTeam leaves photoUrl untouched.
      String? photoUrl;
      if (_pickedImage != null) {
        photoUrl = await _cloudinaryService.uploadProfilePicture(_pickedImage!);
        if (photoUrl == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Photo upload failed — other changes were still saved.',
              ),
            ),
          );
        }
      }

      await _teamService.updateTeam(
        teamId: widget.team.id,
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        photoUrl: photoUrl, // ✅ new
      );

      if (!mounted) return;

      SuccessDialog.show(
        context,
        title: 'Team Updated!',
        message: 'Your changes have been saved successfully.',
        onDone: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // back to team profile
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmDeleteTeam() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Team?',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This will permanently delete "${widget.team.name}" and all its data. This action cannot be undone.',
          style: AppTextStyles.date,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(color: AppColors.textDark),
            ),
          ),
          TextButton(
            onPressed: _isDeleting ? null : _deleteTeam,
            child: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                  )
                : const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeam() async {
    setState(() => _isDeleting = true);

    try {
      await _teamService.deleteTeam(widget.team.id);

      if (!mounted) return;

      Navigator.pop(context); // close confirm dialog
      Navigator.pop(context); // close EditTeamScreen
      Navigator.pop(context); // close TeamProfileScreen → back to MyTeamsScreen
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close confirm dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete team: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.28;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 60),

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: AppColors.textDark,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Edit Team', style: AppTextStyles.subheading),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Form ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar ────────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              color: AppColors.avatarPlaceholder,
                              shape: BoxShape.circle,
                              image: _pickedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_pickedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (widget.team.photoUrl != null &&
                                            widget.team.photoUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              widget.team.photoUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                            ),
                            child:
                                _pickedImage == null &&
                                    (widget.team.photoUrl == null ||
                                        widget.team.photoUrl!.isEmpty)
                                ? Center(
                                    child: Text(
                                      widget.team.name.isNotEmpty
                                          ? widget.team.name[0].toUpperCase()
                                          : '?',
                                      style: AppTextStyles.subheading.copyWith(
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.textDark,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Team Name',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _EditField(controller: _nameController, hint: 'Team name'),

                  const SizedBox(height: 18),

                  Text(
                    'Team Bio',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _EditField(
                    controller: _bioController,
                    hint: 'Describe your team ........',
                    maxLines: 4,
                  ),

                  const SizedBox(height: 40),

                  // ── Save button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textDark,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isSaving ? null : _saveTeam,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save Changes',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Delete button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isDeleting ? null : _confirmDeleteTeam,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      label: Text(
                        'Delete Team',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit field ────────────────────────────────────────────────────────────────
class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _EditField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textDark, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
