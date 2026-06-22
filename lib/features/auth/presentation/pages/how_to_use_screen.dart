import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/presentation/pages/main_scaffold.dart';

class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Slides content ───────────────────────────────────────────────────────
  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      number: '1',
      image: 'assets/images/1.png',
      description:
          'Organize meetings on a clear weekly grid, all in one place.',
    ),
    _OnboardingSlide(
      number: '2',
      image: 'assets/images/2.png',
      description: 'Link teammates together so everyone stays in sync.',
    ),
    _OnboardingSlide(
      number: '3',
      image: 'assets/images/3.png',
      description: 'Chat with your team and keep every conversation organized.',
    ),
  ];

  void _onStartUsing() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _onStartUsing();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),

            // ── Title ─────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('How To Use Hourlink?', style: AppTextStyles.subheading),
                  const SizedBox(height: 8),
                  Text(
                    'a complete simple guide on how to use our app',
                    style: AppTextStyles.date,
                  ),
                ],
              ),
            ),

            // ── Carousel ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _SlideContent(slide: slide, screenWidth: screenWidth);
                },
              ),
            ),

            // ── Page indicator dots ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.textGrey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ── CTA button — half-circle "bump" like the design ──────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.08,
                0,
                screenWidth * 0.08,
                30,
              ),
              child: GestureDetector(
                onTap: _nextPage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: screenWidth * 0.40,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.textDark, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isLastPage ? 'Start using' : 'Next',
                          key: ValueKey(isLastPage),
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLastPage
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single slide data ─────────────────────────────────────────────────────────
class _OnboardingSlide {
  final String number;
  final String image;
  final String description;

  const _OnboardingSlide({
    required this.number,
    required this.image,
    required this.description,
  });
}

// ── Single slide content ──────────────────────────────────────────────────────
class _SlideContent extends StatelessWidget {
  final _OnboardingSlide slide;
  final double screenWidth;

  const _SlideContent({required this.slide, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Illustration ────────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              slide.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Icon(
                Icons.image_outlined,
                size: screenWidth * 0.3,
                color: AppColors.textGrey,
              ),
            ),
          ),

          const SizedBox(height: 28),
          // ── Short description ─────────────────────────────────────────
          Text(
            slide.description,
            style: AppTextStyles.date,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
