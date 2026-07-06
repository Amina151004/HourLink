import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:hourlink/features/auth/data/services/auth_service.dart';

/// Service Google Calendar qui réutilise l'instance GoogleSignIn de AuthService.
/// Pas de double connexion — le même token Google sert Firebase ET Calendar.
class GoogleCalendarService {
  static final GoogleCalendarService _instance =
      GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  final _authService = AuthService();
  gcal.CalendarApi? _calendarApi;

  // ─────────────────────────────────────────────
  // INITIALISATION
  // ─────────────────────────────────────────────

  /// Initialise l'API Calendar en utilisant la session Google existante.
  /// À appeler une fois après la connexion dans AuthService.
  Future<bool> init() async {
    try {
      final authClient = await _authService.googleSignIn.authenticatedClient();
      debugPrint('[FreeBusy] authClient: $authClient');
      debugPrint(
        '[FreeBusy] currentUser: ${_authService.googleSignIn.currentUser}',
      );
      if (authClient == null) return false;
      _calendarApi = gcal.CalendarApi(authClient);
      return true;
    } catch (e) {
      debugPrint('[GoogleCalendarService] Erreur init: $e');
      return false;
    }
  }

  bool get isReady => _calendarApi != null;

  Future<bool> _ensureReady() async {
    if (isReady) return true;
    return await init();
  }

  void dispose() => _calendarApi = null;

  // ─────────────────────────────────────────────
  // CRÉER UN ÉVÉNEMENT
  // ─────────────────────────────────────────────

  Future<String?> createMeetingEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String description = '',
    List<String> attendeeEmails = const [],
    String? meetingId,
  }) async {
    if (!await _ensureReady()) return null;
    try {
      final event = gcal.Event(
        summary: title,
        description: meetingId != null
            ? '$description\n\n[HourLink Meeting ID: $meetingId]'
            : description,
        start: gcal.EventDateTime(dateTime: start, timeZone: 'Africa/Algiers'),
        end: gcal.EventDateTime(dateTime: end, timeZone: 'Africa/Algiers'),
        attendees: attendeeEmails
            .map((email) => gcal.EventAttendee(email: email))
            .toList(),
        guestsCanModify: false,
        guestsCanInviteOthers: false,
      );
      final created = await _calendarApi!.events.insert(
        event,
        'primary',
        sendUpdates: 'all',
      );
      debugPrint('[GoogleCalendarService] Événement créé: ${created.id}');
      return created.id;
    } catch (e) {
      debugPrint('[GoogleCalendarService] Erreur createMeetingEvent: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // LIRE LES ÉVÉNEMENTS
  // ─────────────────────────────────────────────

  Future<List<CalendarEvent>> getUpcomingEvents({
    int maxResults = 20,
    int daysAhead = 30,
  }) async {
    if (!await _ensureReady()) return [];
    try {
      final now = DateTime.now();
      final result = await _calendarApi!.events.list(
        'primary',
        timeMin: now,
        timeMax: now.add(Duration(days: daysAhead)),
        maxResults: maxResults,
        singleEvents: true,
        orderBy: 'startTime',
      );
      return (result.items ?? [])
          .map((e) => CalendarEvent.fromGoogleEvent(e))
          .toList();
    } catch (e) {
      debugPrint('[GoogleCalendarService] Erreur getUpcomingEvents: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // CRÉNEAUX OCCUPÉS (pour le scheduling HourLink)
  // ─────────────────────────────────────────────

  Future<Map<String, List<TimeSlot>>> getBusySlots({
    required List<String> emails,
    required DateTime start,
    required DateTime end,
  }) async {
    debugPrint('[FreeBusy] getBusySlots called, emails: $emails');
    final ready = await _ensureReady();
    debugPrint('[FreeBusy] ensureReady result: $ready');
    if (!ready) return {};

    try {
      final request = gcal.FreeBusyRequest(
        timeMin: start,
        timeMax: end,
        timeZone: 'Africa/Algiers',
        items: emails.map((e) => gcal.FreeBusyRequestItem(id: e)).toList(),
      );
      final response = await _calendarApi!.freebusy.query(request);
      final Map<String, List<TimeSlot>> busyMap = {};
      response.calendars?.forEach((email, calInfo) {
        // 🔍 DEBUG — tells you WHY a calendar came back empty
        if (calInfo.errors != null && calInfo.errors!.isNotEmpty) {
          for (final err in calInfo.errors!) {
            debugPrint(
              '[FreeBusy] $email error -> domain=${err.domain}, reason=${err.reason}',
            );
          }
        }
        debugPrint('[FreeBusy] $email raw busy: ${calInfo.busy}');

        busyMap[email] = (calInfo.busy ?? [])
            .map((p) => TimeSlot(start: p.start!, end: p.end!))
            .toList();
      });
      return busyMap;
    } catch (e) {
      debugPrint('[GoogleCalendarService] Erreur getBusySlots: $e');
      return {};
    }
  }

  // ─────────────────────────────────────────────
  // METTRE À JOUR / SUPPRIMER
  // ─────────────────────────────────────────────

  Future<bool> updateMeetingEvent({
    required String eventId,
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
    List<String>? attendeeEmails,
  }) async {
    if (!await _ensureReady()) return false;
    try {
      final existing = await _calendarApi!.events.get('primary', eventId);
      final updated = gcal.Event(
        summary: title ?? existing.summary,
        description: description ?? existing.description,
        start: start != null
            ? gcal.EventDateTime(dateTime: start, timeZone: 'Africa/Algiers')
            : existing.start,
        end: end != null
            ? gcal.EventDateTime(dateTime: end, timeZone: 'Africa/Algiers')
            : existing.end,
        attendees: attendeeEmails != null
            ? attendeeEmails.map((e) => gcal.EventAttendee(email: e)).toList()
            : existing.attendees,
      );
      await _calendarApi!.events.update(
        updated,
        'primary',
        eventId,
        sendUpdates: 'all',
      );
      return true;
    } catch (e) {
      debugPrint('[GoogleCalendarService] Erreur updateMeetingEvent: $e');
      return false;
    }
  }

  Future<bool> deleteMeetingEvent(String eventId) async {
    if (!await _ensureReady()) return false;
    try {
      await _calendarApi!.events.delete('primary', eventId);
      return true;
    } catch (e) {
      debugPrint('[GoogleCalendarService] Erreur deleteMeetingEvent: $e');
      return false;
    }
  }
}

// ─────────────────────────────────────────────
// MODÈLES LOCAUX
// ─────────────────────────────────────────────

class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;
  final List<String> attendeeEmails;
  final bool isAllDay;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
    this.attendeeEmails = const [],
    this.isAllDay = false,
  });

  factory CalendarEvent.fromGoogleEvent(gcal.Event event) {
    final isAllDay = event.start?.date != null;
    DateTime parseStart() {
      if (isAllDay) return DateTime.parse(event.start!.date! as String);
      return event.start?.dateTime?.toLocal() ?? DateTime.now();
    }

    DateTime parseEnd() {
      if (isAllDay) return DateTime.parse(event.end!.date! as String);
      return event.end?.dateTime?.toLocal() ?? DateTime.now();
    }

    return CalendarEvent(
      id: event.id ?? '',
      title: event.summary ?? 'Sans titre',
      start: parseStart(),
      end: parseEnd(),
      description: event.description,
      attendeeEmails: event.attendees?.map((a) => a.email ?? '').toList() ?? [],
      isAllDay: isAllDay,
    );
  }
}

class TimeSlot {
  final DateTime start;
  final DateTime end;
  TimeSlot({required this.start, required this.end});
  Duration get duration => end.difference(start);
  bool overlaps(TimeSlot other) =>
      start.isBefore(other.end) && end.isAfter(other.start);
}
