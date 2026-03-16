import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/auth/presentation/constants/onboarding_keys.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _saving = false;

  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      icon: Icons.explore_rounded,
      title: 'Capture moments as they happen',
      description:
          'Drop cities, routes, and photos on a live map while your memories are fresh.',
      accentColor: Color(0xFF1F6F78),
    ),
    _OnboardingItem(
      icon: Icons.timeline_rounded,
      title: 'Turn chaos into a clear timeline',
      description:
          'Dora organizes every stop into an elegant, editable travel storyline.',
      accentColor: Color(0xFF8A5A44),
    ),
    _OnboardingItem(
      icon: Icons.auto_awesome_rounded,
      title: 'Publish a story that feels cinematic',
      description:
          'Export polished travelogues and share your trip with one clean flow.',
      accentColor: Color(0xFF2A7B66),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_saving) {
      return;
    }

    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingKeys.hasSeenOnboarding, true);
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;

    if (!mounted) {
      return;
    }

    context.go(isLoggedIn ? Routes.feed : Routes.login);
  }

  Future<void> _goNext() async {
    if (_currentIndex == _items.length - 1) {
      await _finishOnboarding();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _items.length - 1;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5EFE8),
              Color(0xFFE7F3F4),
              Color(0xFFF8F3EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.allLg,
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: _saving ? null : _finishOnboarding,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _items.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _OnboardingCard(item: item);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentIndex == i ? 26 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == i
                              ? AppColors.accent
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentIndex == 0 || _saving
                            ? null
                            : () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _goNext,
                        child: Text(
                          isLast ? 'Start with Dora' : 'Continue',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: AppSpacing.allXl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 108,
            width: 108,
            decoration: BoxDecoration(
              color: item.accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: item.accentColor.withValues(alpha: 0.24),
              ),
            ),
            child: Icon(item.icon, size: 52, color: item.accentColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
}
