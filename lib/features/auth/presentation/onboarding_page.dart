import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      title: 'Thrifty.',
      description:
          'Your pocket finance manager. Track spending, manage accounts, and build better money habits.',
      showLogo: true,
    ),
    _SlideData(
      title: 'Track accounts effortlessly',
      description:
          'Keep cash, bank and wallet balances in one place with a clean timeline.',
      showLogo: false,
      icon: Icons.account_balance_wallet_rounded,
    ),
    _SlideData(
      title: 'Grow savings confidently',
      description:
          'Use goals and analytics to turn daily choices into long-term progress.',
      showLogo: false,
      icon: Icons.trending_up_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage == _slides.length - 1) {
      context.go('/onboarding/setup');
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/onboarding/setup'),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = _slides[index];
                    return _OnboardingSlide(item: item);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.grey400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Continue' : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.item});

  final _SlideData item;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final iconBackground = Theme.of(context).colorScheme.surface;
    final iconBorder = Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.showLogo)
            Image.asset(
              'assets/icons/app_icon_without_bg.png',
              width: 104,
              height: 104,
            )
          else if (item.icon != null)
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: iconBackground,
                border: Border.all(color: iconBorder),
              ),
              child: Icon(item.icon!, size: 38, color: AppColors.primary),
            ),
          const SizedBox(height: 22),
          if (item.showLogo && item.icon != null) ...[
            Icon(item.icon!, size: 34, color: AppColors.primary),
            const SizedBox(height: 18),
          ],
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.title,
    required this.description,
    required this.showLogo,
    this.icon,
  });

  final String title;
  final String description;
  final bool showLogo;
  final IconData? icon;
}
