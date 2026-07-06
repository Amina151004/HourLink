import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I create a meeting?',
      answer:
          'Open a team, tap "Create Meeting", and pick a date range. '
          'HourLink automatically finds the first time slot when every '
          'team member is free.',
    ),
    _FaqItem(
      question: 'How does smart scheduling work?',
      answer:
          'HourLink checks everyone\'s Google Calendar free/busy status '
          'during work hours (9am–6pm, weekdays) and suggests the first '
          'one-hour slot with no conflicts.',
    ),
    _FaqItem(
      question: 'Do I need to connect Google Calendar?',
      answer:
          'Yes — calendar access is required for smart scheduling to check '
          'your availability. You can manage this from Settings.',
    ),
    _FaqItem(
      question: 'How do I add members to a team?',
      answer:
          'Open your team profile and tap the add member icon. You can '
          'invite people by email or username.',
    ),
    _FaqItem(
      question: 'Can I message someone directly?',
      answer:
          'Yes — go to the Chats tab and start a new direct message from '
          'any team member\'s profile.',
    ),
    _FaqItem(
      question: 'How do I edit my profile?',
      answer:
          'Go to Settings → Edit Profile to update your name, photo, title, '
          'and location.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    size: 28,
                    color: AppColors.textDark,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Help Center', style: AppTextStyles.subheading),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Text(
              'Frequently asked questions',
              style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
            ),
          ),

          const SizedBox(height: 16),

          // ── FAQ list ──────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ).copyWith(bottom: 40),
              itemCount: _faqs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _FaqTile(item: _faqs[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;

  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textDark, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.item.answer,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textGrey,
                      height: 1.4,
                    ),
                  ),
                ),
                secondChild: const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
