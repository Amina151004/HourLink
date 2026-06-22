import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/presentation/widgets/app_text_field.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';

class CreateMeetingScreen extends StatefulWidget {
  final List<Team> allTeams;

  const CreateMeetingScreen({super.key, required this.allTeams});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  Team? _selectedTeam;
  DateTime? _startDate;
  DateTime? _endDate;

  String? _generatedResult; // ✅ rempli par l'algorithme plus tard
  bool _isGenerating = false;

  // ✅ remplace par l'uid réel de FirebaseAuth.instance.currentUser!.uid
  static const String _currentUserId = '1';

  late final List<Team> _ownedTeams = widget.allTeams
      .where((team) => team.isOwnedBy(_currentUserId))
      .toList();

  @override
  void initState() {
    super.initState();
    if (_ownedTeams.isNotEmpty) _selectedTeam = _ownedTeams.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ── 🔲 Point d'entrée de l'algorithme — à implémenter plus tard ─────────
  Future<String> _findBestMeetingTime({
    required Team team,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // TODO: smart scheduling algorithm
    return '';
  }

  Future<void> _onGeneratePressed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeam == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedResult = null;
    });

    final result = await _findBestMeetingTime(
      team: _selectedTeam!,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    setState(() {
      _isGenerating = false;
      _generatedResult = result.isEmpty ? null : result;
    });
  }

  // ✅ Confirme/sauvegarde le meeting trouvé — déclenché par le bouton "+"
  void _onConfirmMeeting() {
    if (_generatedResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate a time slot first')),
      );
      return;
    }

    // ── Ici tu sauvegarderas le meeting vers Firestore plus tard ─────────
    SuccessDialog.show(
      context,
      title: 'Meeting Created!',
      message:
          '"${_titleController.text.trim()}" has been scheduled for ${_selectedTeam!.name} at $_generatedResult.',
      onDone: () {
        Navigator.pop(context); // ferme le dialog
        Navigator.pop(context); // retourne à l'écran précédent
      },
    );
  }

  void _resetResult() {
    setState(() => _generatedResult = null);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: 10,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              // ── Header ────────────────────────────────────────────────
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Create a New Meeting',
                      style: AppTextStyles.subheading.copyWith(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _onConfirmMeeting,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Meeting title ─────────────────────────────────────────
              Text(
                'Meeting Title :',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _titleController,
                hint: 'Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a meeting title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ── Team selector — owned teams only ─────────────────────
              Text(
                'Select Meeting Team :',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _TeamDropdown(
                teams: _ownedTeams,
                selectedTeam: _selectedTeam,
                onChanged: (team) => setState(() => _selectedTeam = team),
              ),

              const SizedBox(height: 24),

              // ── Date range ─────────────────────────────────────────────
              Text(
                'Select your time:',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: _formatDate(_startDate),
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('-', style: AppTextStyles.body),
                  ),
                  Expanded(
                    child: _DatePickerField(
                      label: _formatDate(_endDate),
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Generate button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isGenerating ? null : _onGeneratePressed,
                  child: _isGenerating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Generate the date and time',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // ── Result field ───────────────────────────────────────────
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.textDark.withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _generatedResult ?? 'Result will appear here',
                    style: AppTextStyles.body.copyWith(
                      color: _generatedResult == null
                          ? AppColors.textGrey
                          : AppColors.textDark,
                      fontWeight: _generatedResult == null
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Delete / clear result ────────────────────────────────
              if (_generatedResult != null)
                Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 26,
                      color: AppColors.textDark,
                    ),
                    onPressed: _resetResult,
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Team dropdown ─────────────────────────────────────────────────────────────
class _TeamDropdown extends StatelessWidget {
  final List<Team> teams;
  final Team? selectedTeam;
  final ValueChanged<Team?> onChanged;

  const _TeamDropdown({
    required this.teams,
    required this.selectedTeam,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textDark, width: 0.5),
        ),
        child: Text(
          'You don\'t own any teams yet',
          style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Team>(
          value: selectedTeam,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textDark,
          ),
          style: AppTextStyles.body.copyWith(color: AppColors.textDark),
          items: teams
              .map(
                (team) => DropdownMenuItem<Team>(
                  value: team,
                  child: Text(team.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Date picker field ─────────────────────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePickerField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textDark, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textDark,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
