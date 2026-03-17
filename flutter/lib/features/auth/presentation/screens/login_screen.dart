import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/utils/validators.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/auth/presentation/widgets/auth_shell.dart';
import 'package:dora/shared/widgets/loading_indicator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.isLoading || _isGoogleLoading;
    final startupReason =
        GoRouterState.of(context).uri.queryParameters['reason'];
    final startupMessage = _startupReasonMessage(startupReason);

    return AuthShell(
      title: 'Welcome back',
      subtitle:
          'Sign in to continue your travel story and pick up where you left off.',
      form: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  'Email address',
                  Icons.mail_outline_rounded,
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: _inputDecoration(
                  'Password',
                  Icons.lock_outline_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: Validators.password,
              ),
              if (startupMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                _AuthErrorBanner(message: startupMessage),
              ],
              if (authState.hasError) ...[
                const SizedBox(height: AppSpacing.md),
                _AuthErrorBanner(
                  message: _friendlyError(
                    authState.error,
                    fallback:
                        "Couldn't sign in. Please check your credentials.",
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _handleLogin,
                  child: isSubmitting
                      ? const _ActionProgress(label: 'Signing in...')
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isSubmitting ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.travel_explore_rounded),
                  label: Text(
                    _isGoogleLoading
                        ? 'Connecting Google...'
                        : 'Continue with Google',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      footer: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'New here?',
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: isSubmitting ? null : () => context.go(Routes.signup),
            child: const Text('Create account'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref.read(authControllerProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
    );
  }

  String _friendlyError(Object? error, {String? fallback}) {
    final text = error?.toString() ?? '';
    if (text.contains('Invalid login credentials')) {
      return 'Email or password is incorrect.';
    }
    if (text.contains('network')) {
      return 'Network issue detected. Please try again.';
    }
    return fallback ?? 'Authentication failed. Please try again.';
  }

  String? _startupReasonMessage(String? reason) {
    if (reason == 'account_conflict') {
      return 'This email is already linked to another sign-in method. '
          'Use your original login method for this account.';
    }
    return null;
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      padding: AppSpacing.allMd,
      child: Text(
        message,
        style: AppTypography.caption.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionProgress extends StatelessWidget {
  const _ActionProgress({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 32,
          child: LoadingIndicator(
            size: 14,
            color: Colors.white,
            centered: false,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}
