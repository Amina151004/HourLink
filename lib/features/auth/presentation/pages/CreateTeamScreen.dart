// ignore: file_names
import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/presentation/widgets/app_text_field.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _membersController = TextEditingController();

  // ── Form key for validation ───────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  // ── Called when checkmark is tapped ──────────────────────────────────────
  void _submit() {
    // validates all fields — if any is empty, shows error under the field
    if (!_formKey.currentState!.validate()) return;

    // show success dialog
    SuccessDialog.show(
      context,
      title: 'Team Created!',
      message:
          'Your team "${_nameController.text.trim()}" has been created successfully.',
      buttonLabel: 'Done',
      onDone: () {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // go back to teams screen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // ── Responsive breakpoints ───────────────────────────────────
            // Scale spacing/avatar/font with screen width, and cap the
            // content width on large screens (tablets / foldables / web)
            // so the form doesn't stretch edge-to-edge.
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

                        // ── Top bar: back arrow + title + checkmark ───────
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
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
                              // ✅ checkmark appears always but only works when fields filled
                              IconButton(
                                icon: const Icon(
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
                            onTap: () {
                              // TODO: add image_picker package later
                            },
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
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: avatarSize * 0.32,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Add a team picture',
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
                            mainAxisAlignment: MainAxisAlignment.start,
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

                              // ── Members ────────────────────────────────
                              Text(
                                'Add Team Members',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppTextField(
                                controller: _membersController,
                                hint: 'name1, name2 ………',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Add at least one member';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: isCompact ? 28 : 40),

                              // ── Delete / clear button ──────────────────
                              Center(
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.textGrey,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    _nameController.clear();
                                    _descController.clear();
                                    _membersController.clear();
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
