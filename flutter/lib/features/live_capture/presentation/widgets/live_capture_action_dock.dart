import 'package:flutter/material.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';

class LiveCaptureActionDock extends StatefulWidget {
  const LiveCaptureActionDock({
    super.key,
    required this.state,
    this.isBusy = false,
    this.onPhoto,
    this.onNote,
    this.onWarn,
    this.onMedia,
    this.onTag,
  });

  final LiveCaptureShellState state;
  final bool isBusy;
  final VoidCallback? onPhoto;
  final VoidCallback? onNote;
  final VoidCallback? onWarn;
  final VoidCallback? onMedia;
  final VoidCallback? onTag;

  @override
  State<LiveCaptureActionDock> createState() => _LiveCaptureActionDockState();
}

class _LiveCaptureActionDockState extends State<LiveCaptureActionDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final List<Animation<double>> _staggerAnims;

  static const int _staggerMs = 40;
  static const int _animMs = 200;
  // total = 4 * staggerMs + animMs = 360ms
  static const int _totalMs = _staggerMs * 4 + _animMs;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );
    _staggerAnims = List.generate(5, (i) {
      final start = (i * _staggerMs) / _totalMs;
      final end = (i * _staggerMs + _animMs) / _totalMs;
      return CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: AnimationTokens.decelerate),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _staggerCtrl.forward();
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final actions = <_ActionMeta>[
      _ActionMeta(
        key: const ValueKey('liveCaptureActionPhoto'),
        icon: Icons.photo_camera_outlined,
        label: 'Photo',
        onTap: widget.onPhoto,
      ),
      _ActionMeta(
        key: const ValueKey('liveCaptureActionNote'),
        icon: Icons.note_add_outlined,
        label: 'Note',
        onTap: widget.onNote,
      ),
      _ActionMeta(
        key: const ValueKey('liveCaptureActionWarn'),
        icon: Icons.warning_amber_rounded,
        label: 'Warn',
        onTap: widget.onWarn,
      ),
      _ActionMeta(
        key: const ValueKey('liveCaptureActionMedia'),
        icon: Icons.videocam_outlined,
        label: 'Media',
        onTap: widget.onMedia,
      ),
      _ActionMeta(
        key: const ValueKey('liveCaptureActionTag'),
        icon: Icons.place_outlined,
        label: 'Tag',
        onTap: widget.onTag,
      ),
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        key: const ValueKey('liveCaptureActionDock'),
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.65)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < actions.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _buildStaggeredPill(
                    index: i,
                    action: actions[i],
                    reduceMotion: reduceMotion,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredPill({
    required int index,
    required _ActionMeta action,
    required bool reduceMotion,
  }) {
    final enabled = _isActionEnabled(
          state: widget.state,
          actionKey: action.key,
        ) &&
        !widget.isBusy &&
        action.onTap != null;

    final pill = _ActionPill(
      key: action.key,
      icon: action.icon,
      label: action.label,
      enabled: enabled,
      onTap: action.onTap,
    );

    if (reduceMotion) return pill;

    return AnimatedBuilder(
      animation: _staggerAnims[index],
      child: pill,
      builder: (context, child) {
        final t = _staggerAnims[index].value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(24.0 * (1.0 - t), 0),
            child: child,
          ),
        );
      },
    );
  }

  bool _isActionEnabled({
    required LiveCaptureShellState state,
    required ValueKey<String> actionKey,
  }) {
    switch (state) {
      case LiveCaptureShellState.active:
        return true;
      case LiveCaptureShellState.paused:
        // Spec §4.4: during Paused, only Note remains enabled.
        return actionKey == const ValueKey('liveCaptureActionNote');
      case LiveCaptureShellState.planned:
      case LiveCaptureShellState.ended:
      case LiveCaptureShellState.blocked:
        return false;
    }
  }
}

class _ActionPill extends StatefulWidget {
  const _ActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final foreground =
        widget.enabled ? AppColors.textPrimary : AppColors.textSecondary;

    return GestureDetector(
      onTapDown:
          widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: (_pressed && widget.enabled) ? 0.90 : 1.0,
        duration: AnimationTokens.fast,
        curve: AnimationTokens.standard,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.45,
          duration: AnimationTokens.normal,
          child: AnimatedContainer(
            duration: AnimationTokens.normal,
            curve: AnimationTokens.standard,
            width: 60,
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.surface
                  : AppColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(widget.icon, size: 18, color: foreground),
                const SizedBox(height: 1),
                Text(
                  widget.label,
                  style: AppTypography.caption.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionMeta {
  const _ActionMeta({
    required this.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final ValueKey<String> key;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}
