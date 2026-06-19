import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Get screen dimensions once ────────────────────────────────────────
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
                // ── Title ───────────────────────────────────────────────────
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

                // ── Illustration ─────────────────────────────────────────────
                Image.asset(
                  'assets/images/welcome.png',
                  height: screenHeight * 0.28, // 28% of screen height
                  width: screenWidth * 0.75, // 75% of screen width
                  fit: BoxFit.contain,
                ),

                SizedBox(height: screenHeight * 0.08),

                // ── Google button ─────────────────────────────────────────────
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 0, 0, 0),
                      width: 0.7,
                    ),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    // ✅ uses screen width instead of fixed 240
                    minimumSize: Size(screenWidth * 0.65, 48),
                    maximumSize: Size(screenWidth * 0.65, 50),
                  ),
                  child: Row(
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

                // ── Caption ───────────────────────────────────────────────────
                Text(
                  'Hourlin uses your google calender data to acheive\nperfect meeting time',
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
