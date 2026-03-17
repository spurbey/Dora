import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/auth/presentation/constants/onboarding_keys.dart';
import 'package:dora/shared/widgets/loading_indicator.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _resolveStartupFlow();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _resolveStartupFlow() async {
    await Future<void>.delayed(const Duration(milliseconds: 1700));
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        prefs.getBool(OnboardingKeys.hasSeenOnboarding) ?? false;
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;

    if (!mounted) {
      return;
    }

    if (!hasSeenOnboarding) {
      context.go(Routes.onboarding);
      return;
    }

    context.go(isLoggedIn ? Routes.feed : Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF123C42),
              Color(0xFF1F6F78),
              Color(0xFF3F838A),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _BackdropOrb(
              top: -80,
              left: -60,
              size: 240,
              color: Color(0x22FFFFFF),
            ),
            const _BackdropOrb(
              bottom: -70,
              right: -40,
              size: 220,
              color: Color(0x2DDFC1AD),
            ),
            SafeArea(
              child: Padding(
                padding: AppSpacing.allLg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1 + (_pulseController.value * 0.08);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        height: 94,
                        width: 94,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.borderXl,
                          color: Colors.white.withValues(alpha: 0.16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Dora',
                      style: AppTypography.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Shape every journey into a story',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const LoadingIndicator(
                      size: 40,
                      color: Colors.white,
                      label: 'Preparing your next adventure...',
                      labelColor: Color(0xFFE5F0F1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
