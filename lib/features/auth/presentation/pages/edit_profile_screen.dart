import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';
import 'package:hourlink/features/auth/data/services/user_service.dart';
import 'package:hourlink/features/auth/data/services/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isUploadingImage = false; // ✅ separate loading state for the avatar
  late String _photoUrl; // ✅ tracks current avatar URL, updates on upload

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _titleController = TextEditingController(text: widget.user.title);
    _locationController = TextEditingController(text: widget.user.location);
    _descriptionController = TextEditingController(
      text: widget.user.description,
    );
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _photoUrl = widget.user.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ✅ Pick + upload a new profile picture via Cloudinary
  Future<void> _pickAndUploadImage() async {
    if (_isUploadingImage) return;

    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    final imageUrl = await _cloudinaryService.uploadProfilePicture(
      File(pickedFile.path),
    );

    if (imageUrl != null) {
      // Save immediately so the new photo persists even if the user
      // navigates away without tapping "Save Changes".
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update({'photoUrl': imageUrl});

      if (mounted) {
        setState(() {
          _photoUrl = imageUrl;
          _isUploadingImage = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ Save profile using UserService
  Future<void> _saveProfile() async {
    if (_isSaving) return; // prevent double submission

    setState(() => _isSaving = true);

    try {
      // Update profile using UserService
      await _userService.updateProfile(
        name: _nameController.text.trim(),
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      // Create updated user object for returning
      final updatedUser = AppUser(
        id: widget.user.id,
        name: _nameController.text.trim(),
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photoUrl: _photoUrl, // ✅ use the possibly-updated photo URL
        createdAt: widget.user.createdAt,
      );

      if (mounted) {
        SuccessDialog.show(
          context,
          title: 'Profile Updated!',
          message: 'Your changes have been saved successfully.',
          onDone: () {
            Navigator.pop(context); // close dialog
            Navigator.pop(context, updatedUser); // return to profile with data
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                Text('Edit Profile', style: AppTextStyles.subheading),
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
                      onTap: _pickAndUploadImage,
                      child: Stack(
                        children: [
                          Container(
                            width: screenWidth * 0.28,
                            height: screenWidth * 0.28,
                            decoration: BoxDecoration(
                              color: AppColors.avatarPlaceholder,
                              shape: BoxShape.circle,
                            ),
                            child: _photoUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _photoUrl,
                                      fit: BoxFit.cover,
                                      width: screenWidth * 0.28,
                                      height: screenWidth * 0.28,
                                      errorBuilder: (_, _, _) => Container(
                                        color: AppColors.avatarPlaceholder,
                                      ),
                                    ),
                                  )
                                : null,
                          ),

                          // ✅ Upload spinner overlay
                          if (_isUploadingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
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
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _FieldLabel('Name'),
                  _EditField(controller: _nameController, hint: 'Your name'),
                  const SizedBox(height: 18),

                  _FieldLabel('Title'),
                  _EditField(
                    controller: _titleController,
                    hint: 'e.g. Freelancer',
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Location'),
                  _EditField(
                    controller: _locationController,
                    hint: 'City, Country',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Description'),
                  _EditField(
                    controller: _descriptionController,
                    hint: 'Write something about yourself ........',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Email'),
                  _EditField(
                    controller: _emailController,
                    hint: 'your.email@gmail.com',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    enabled: false, // ✅ Email should be read-only
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Phone'),
                  _EditField(
                    controller: _phoneController,
                    hint: '0550-00-00-00',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
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
                      onPressed: _isSaving
                          ? null
                          : _saveProfile, // ✅ disable when saving
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
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

// ── Field label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ── Edit field ────────────────────────────────────────────────────────────────
class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool enabled;

  const _EditField({
    required this.controller,
    required this.hint,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors.white : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled ? AppColors.textDark : AppColors.textGrey,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        enabled: enabled,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textGrey),
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: AppColors.textGrey)
              : null,
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
