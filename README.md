# HourLink

HourLink is a Flutter mobile app for team coordination, scheduling, and communication. It brings together team management, real-time chat, meeting scheduling, and user profiles in one place, backed by Firebase and integrated with Google Calendar.

## Features

- **Team Management** — create teams, manage members, and track activity
- **Direct Messaging** — real-time 1:1 chat powered by Firestore snapshots
- **Meeting Scheduling** — schedule meetings and (in progress) automatically find the best time slot across a team using Google Calendar FreeBusy data
- **User Profiles** — editable profile with title, location, description, and photo
- **Dark Mode** — app-wide theme toggle with persisted preference
- **Google Sign-In** — single sign-on for both Firebase Auth and Google Calendar API access

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter / Dart |
| Backend | Firebase (Auth, Firestore, Cloud Messaging) |
| Auth & Calendar | Google Sign-In, Google Calendar API (FreeBusy, Events) |
| Media Storage | Cloudinary |
| Build | Gradle (Android), FlutterFire CLI |
| Design | Figma (early-stage UI/UX) |

## Architecture

HourLink uses a lightweight service-based architecture rather than a state management package:

- Plain Dart service classes (`TeamService`, `ChatService`, `AuthService`, `UserService`, `CloudinaryService`, `GoogleCalendarService`) are instantiated directly where needed.
- Reactivity is handled with `StreamBuilder` / `ValueListenableBuilder` bound to Firestore snapshot streams.
- No Provider, Riverpod, or Bloc — state stays close to the widgets that use it.

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- A Firebase project with Auth, Firestore, and Cloud Messaging enabled
- A Google Cloud project with the Calendar API enabled and OAuth consent configured
- A Cloudinary account for media storage

### Setup

1. Clone the repository
   ```bash
   git clone https://github.com/<your-username>/hourlink.git
   cd hourlink
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase
   ```bash
   flutterfire configure
   ```
   This generates `firebase_options.dart` and wires up your Firebase project.

4. Add your Cloudinary credentials and Google Calendar API keys to your environment/config as required by `CloudinaryService` and `GoogleCalendarService`.

5. Run the app
   ```bash
   flutter run
   ```

### Android Build Notes

If you're behind a network that blocks `dl.google.com` or the standard Maven repositories, add Aliyun mirror URLs to your Gradle repositories to unblock dependency resolution.

## Project Status

HourLink is feature-complete at the Flutter layer with active Firebase backend integration. Ongoing work includes:

- Finishing the smart meeting scheduler (`_findBestMeetingTime`), which uses the Google Calendar FreeBusy API to find the first open one-hour slot across team members on weekdays, 9am–6pm
- Moving from a per-screen user cache to a shared, TTL-based cache so profile updates reflect mid-session
- Push notifications (currently deferred — requires upgrading to the Firebase Blaze plan; in-app notifications are used in the meantime)

## Contributing

This is currently a solo project in active development. Issues and suggestions are welcome.

