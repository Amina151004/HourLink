import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/services/meeting_service.dart';
import 'package:hourlink/features/auth/data/services/google_calendar_service.dart';
import 'package:hourlink/features/auth/presentation/widgets/app_text_field.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';

class CreateMeetingScreen extends StatefulWidget {
  final List<Team> allTeams;
  final String currentUserId;

  const CreateMeetingScreen({
    super.key,
    required this.allTeams,
    required this.currentUserId,
  });

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  final MeetingService _meetingService = MeetingService();
  final GoogleCalendarService _calendarService = GoogleCalendarService();

  // ── Current user ID directly from AuthService ───────────────────────────
  String get _currentUserId => widget.currentUserId;

  Team? _selectedTeam;
  DateTime? _startDate;
  DateTime? _endDate;

  DateTime? _generatedDateTime;
  bool _isGenerating = false;
  bool _isSaving = false;

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

  String _formatDateTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'pm' : 'am';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${_formatDate(dt)} at $h12:$m$period';
  }

  // ── 🔲 Algorithm — uses real Google Calendar busy slots ─────────────────
  Future<DateTime?> _findBestMeetingTime({
    required Team team,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final attendeeEmails = team.members.map((m) => m.email).toList();

    final busySlots = await _calendarService.getBusySlots(
      emails: attendeeEmails,
      start: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
      end: DateTime(endDate.year, endDate.month, endDate.day, 23, 59),
    );

    debugPrint('Busy slots fetched: $busySlots');

    // Flatten all busy slots from all members into one list
    final List<TimeSlot> allBusy = busySlots.values
        .expand((slots) => slots)
        .toList();

    // Working hours: 9am – 6pm, 1-hour meeting slots, 30-min steps
    const startHour = 9;
    const endHour = 18;
    const meetingDuration = Duration(hours: 1);
    const step = Duration(minutes: 30);

    // Iterate day by day within the selected range
    DateTime day = DateTime(startDate.year, startDate.month, startDate.day);
    final lastDay = DateTime(endDate.year, endDate.month, endDate.day);

    while (!day.isAfter(lastDay)) {
      // Skip weekends
      if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
        DateTime candidate = DateTime(
          day.year,
          day.month,
          day.day,
          startHour,
          0,
        );
        final dayEnd = DateTime(day.year, day.month, day.day, endHour, 0);

        while (candidate.add(meetingDuration).isBefore(dayEnd) ||
            candidate.add(meetingDuration).isAtSameMomentAs(dayEnd)) {
          final slot = TimeSlot(
            start: candidate,
            end: candidate.add(meetingDuration),
          );

          // Check if this slot overlaps with any member's busy period
          final hasConflict = allBusy.any((busy) => slot.overlaps(busy));

          if (!hasConflict) {
            debugPrint('[Scheduler] Best slot found: ${slot.start}');
            return slot.start;
          }

          candidate = candidate.add(step);
        }
      }

      day = day.add(const Duration(days: 1));
    }

    debugPrint('[Scheduler] No free slot found in range');
    return null; // no free slot found
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
      _generatedDateTime = null;
    });

    final result = await _findBestMeetingTime(
      team: _selectedTeam!,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    if (!mounted) return;
    setState(() {
      _isGenerating = false;
      _generatedDateTime = result;
    });
  }

  // ✅ Saves the meeting to Firestore + creates Google Calendar event
  Future<void> _onConfirmMeeting() async {
    if (_generatedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate a time slot first')),
      );
      return;
    }
    if (_selectedTeam == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 1️⃣ save meeting to Firestore
      final meeting = await _meetingService.createMeeting(
        teamId: _selectedTeam!.id,
        title: _titleController.text.trim(),
        scheduledAt: _generatedDateTime!,
        platform: 'zoom',
      );

      // 2️⃣ also create a Google Calendar event for the team
      await _calendarService.createMeetingEvent(
        title: _titleController.text.trim(),
        start: _generatedDateTime!,
        end: _generatedDateTime!.add(const Duration(hours: 1)),
        description: 'HourLink meeting for ${_selectedTeam!.name}',
        attendeeEmails: _selectedTeam!.members.map((m) => m.email).toList(),
        meetingId: meeting.id,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      SuccessDialog.show(
        context,
        title: 'Meeting Created!',
        message:
            '"${_titleController.text.trim()}" has been scheduled for ${_selectedTeam!.name} at ${_formatDateTime(_generatedDateTime!)}.',
        onDone: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // go back
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save meeting: $e')));
    }
  }

  void _resetResult() {
    setState(() => _generatedDateTime = null);
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
                    icon: Icon(
                      Icons.chevron_left,
                      color: AppColors.textDark,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Create a New Meeting',
                      style: AppTextStyles.subheading.copyWith(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _isSaving
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.add, color: AppColors.textDark),
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
                      color: AppColors.textDark.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _generatedDateTime == null
                        ? 'Result will appear here'
                        : _formatDateTime(_generatedDateTime!),
                    style: AppTextStyles.body.copyWith(
                      color: _generatedDateTime == null
                          ? AppColors.textGrey
                          : AppColors.textDark,
                      fontWeight: _generatedDateTime == null
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Delete / clear result ────────────────────────────────
              if (_generatedDateTime != null)
                Center(
                  child: IconButton(
                    icon: Icon(
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
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textDark),
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
