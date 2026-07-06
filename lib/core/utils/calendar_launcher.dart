import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the user's Google Calendar — tries the native app deep link first,
/// falls back to the web version if the app isn't installed.
Future<void> openGoogleCalendar(BuildContext context) async {
  final appUri = Uri.parse('googlecalendar://');
  final webUri = Uri.parse('https://calendar.google.com/calendar/u/0/r');

  try {
    final canOpenApp = await canLaunchUrl(appUri);
    if (canOpenApp) {
      await launchUrl(appUri);
      return;
    }
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Calendar.')),
      );
    }
  }
}
