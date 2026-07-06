import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/services/auth_service.dart';
import 'package:hourlink/features/auth/data/services/google_calendar_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── State variables ───────────────────────────────────────────────────────
  final _authService = AuthService();
  bool _isLoading = false;

  // ── Sign in logic ─────────────────────────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final userCredential = await _authService.signInWithGoogle();

    if (!mounted) return;

    if (userCredential != null) {
      // ✅ Initialise Google Calendar après connexion réussie
      await GoogleCalendarService().init();
    }

    setState(() => _isLoading = false);

    // No navigation here on purpose: main.dart's StreamBuilder listens to
    // authStateChanges() and swaps to HowToUseScreen / MainScaffold as
    // soon as sign-in succeeds.
    if (userCredential == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in cancelled')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Screen dimensions ─────────────────────────────────────────────────
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Title ──────────────────────────────────────────────────
                Text(
                  "Welcome To HourLink!",
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "Enter your credentials to access your workspace",
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: screenHeight * 0.08),

                // ── Illustration ───────────────────────────────────────────
                Image.asset(
                  'assets/images/welcome.png',
                  height: screenHeight * 0.28,
                  width: screenWidth * 0.75,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: screenHeight * 0.08),

                // ── Google button ──────────────────────────────────────────
                OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 0, 0, 0),
                      width: 0.7,
                    ),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(screenWidth * 0.65, 48),
                    maximumSize: Size(screenWidth * 0.65, 50),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sign in with ',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'G',
                                    style: TextStyle(
                                      color: Color(0xFF4285F4),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'o',
                                    style: TextStyle(
                                      color: Color(0xFFEA4335),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'o',
                                    style: TextStyle(
                                      color: Color(0xFFFBBC05),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'g',
                                    style: TextStyle(
                                      color: Color(0xFF4285F4),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'l',
                                    style: TextStyle(
                                      color: Color(0xFF34A853),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'e',
                                    style: TextStyle(
                                      color: Color(0xFFEA4335),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // ── Caption ────────────────────────────────────────────────
                Text(
                  'HourLink uses your Google Calendar data to achieve\nperfect meeting times',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
