import 'package:flutter/material.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';

class LiveCaptureTopBar extends StatefulWidget {
  const LiveCaptureTopBar({
    super.key,
    required this.tripName,
    required this.state,
    required this.syncLabel,
    required this.onBack,
    this.syncKind,
    this.onOverflow,
    this.resolverBadgeCount = 0,
    this.onResolverTap,
    this.advisoryUnreadCount = 0,
    this.onAdvisoryTap,
  });

  final String tripName;
  final LiveCaptureShellState state;
  final String syncLabel;
  final VoidCallback onBack;
  final EditorSyncStatusKind? syncKind;
  final VoidCallback? onOverflow;
  final int resolverBadgeCount;
  final VoidCallback? onResolverTap;
  final int advisoryUnreadCount;
  final VoidCallback? onAdvisoryTap;

  @override
  State<LiveCaptureTopBar> createState() => _LiveCaptureTopBarState();
}

class _LiveCaptureTopBarState extends State<LiveCaptureTopBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.state == LiveCaptureShellState.active) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiveCaptureTopBar old) {
    super.didUpdateWidget(old);
    if (widget.state == LiveCaptureShellState.active &&
        !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.state != LiveCaptureShellState.active &&
        _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _syncLabelColor(EditorSyncStatusKind? kind) {
    switch (kind) {
      case EditorSyncStatusKind.synced:
        return AppColors.success;
      case EditorSyncStatusKind.blocked:
        return AppColors.error;
      case EditorSyncStatusKind.syncing:
        return AppColors.accent;
      case null:
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateMeta = _stateMeta(widget.state);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Container(
      key: const ValueKey('liveCaptureTopBar'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.88),
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ultraCompact = constraints.maxWidth < 220;
          final compactStateLabel = _compactStateLabel(widget.state);
          final isPulsingState =
              widget.state == LiveCaptureShellState.active && !reduceMotion;

          final iconWidget =
              Icon(stateMeta.icon, size: 11, color: stateMeta.foreground);
          final pulsingIcon = isPulsingState
              ? ScaleTransition(scale: _pulseScale, child: iconWidget)
              : iconWidget;

          return Row(
            children: [
              Material(
                color: AppColors.surface,
                shape: const CircleBorder(),
                child: InkWell(
                  key: const ValueKey('liveCaptureBack'),
                  customBorder: const CircleBorder(),
                  onTap: widget.onBack,
                  child: SizedBox(
                    width: ultraCompact ? 30 : 34,
                    height: ultraCompact ? 30 : 34,
                    child: const Icon(Icons.arrow_back, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tripName,
                      key: const ValueKey('liveCaptureTripName'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 3,
                      children: [
                        // Badge with AnimatedSwitcher keyed by state
                        Container(
                          key: const ValueKey('liveCaptureStateBadge'),
                          child: AnimatedSwitcher(
                            duration: AnimationTokens.normal,
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: Container(
                              key: ValueKey('badge_${widget.state.name}'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: stateMeta.background,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  pulsingIcon,
                                  const SizedBox(width: 3),
                                  Text(
                                    ultraCompact
                                        ? compactStateLabel
                                        : stateMeta.label,
                                    key: const ValueKey(
                                      'liveCaptureStateLabel',
                                    ),
                                    style: AppTypography.caption.copyWith(
                                      color: stateMeta.foreground,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!ultraCompact)
                          AnimatedDefaultTextStyle(
                            duration: AnimationTokens.fast,
                            curve: AnimationTokens.standard,
                            style: AppTypography.caption.copyWith(
                              color: _syncLabelColor(widget.syncKind),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            child: Text(
                              widget.syncLabel,
                              key: const ValueKey('liveCaptureSyncLabel'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.resolverBadgeCount > 0 &&
                  widget.onResolverTap != null)
                _TopBarBadge(
                  icon: Icons.place_outlined,
                  count: widget.resolverBadgeCount,
                  tint: AppColors.warning,
                  tooltip: 'Unresolved captures',
                  onTap: widget.onResolverTap!,
                ),
              if (widget.onAdvisoryTap != null)
                _TopBarBadge(
                  icon: Icons.chat_bubble_outline,
                  count: widget.advisoryUnreadCount,
                  tint: AppColors.accent,
                  tooltip: 'Chat with Dora',
                  onTap: widget.onAdvisoryTap!,
                  alwaysShow: true,
                ),
              IconButton(
                key: const ValueKey('liveCaptureMore'),
                onPressed: widget.onOverflow ?? () {},
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, size: 18),
              ),
            ],
          );
        },
      ),
    );
  }

  String _compactStateLabel(LiveCaptureShellState value) {
    switch (value) {
      case LiveCaptureShellState.active:
        return 'On';
      case LiveCaptureShellState.paused:
        return 'Paused';
      case LiveCaptureShellState.ended:
        return 'Ended';
      case LiveCaptureShellState.blocked:
        return 'Blocked';
      case LiveCaptureShellState.planned:
        return 'Ready';
    }
  }

  _StateMeta _stateMeta(LiveCaptureShellState value) {
    switch (value) {
      case LiveCaptureShellState.active:
        return const _StateMeta(
          label: 'Active',
          icon: Icons.gps_fixed,
          foreground: AppColors.success,
          background: Color(0xFFE8F7F0),
        );
      case LiveCaptureShellState.paused:
        return const _StateMeta(
          label: 'Paused',
          icon: Icons.pause_circle,
          foreground: AppColors.warning,
          background: Color(0xFFFEF6E9),
        );
      case LiveCaptureShellState.ended:
        return const _StateMeta(
          label: 'Ended',
          icon: Icons.flag,
          foreground: AppColors.textSecondary,
          background: Color(0xFFEFEFEF),
        );
      case LiveCaptureShellState.blocked:
        return const _StateMeta(
          label: 'Sync Blocked',
          icon: Icons.error_outline,
          foreground: AppColors.error,
          background: Color(0xFFFDEBEC),
        );
      case LiveCaptureShellState.planned:
        return const _StateMeta(
          label: 'Ready',
          icon: Icons.play_circle_outline,
          foreground: AppColors.accent,
          background: Color(0xFFE8F4F5),
        );
    }
  }
}

class _StateMeta {
  const _StateMeta({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
}

class _TopBarBadge extends StatelessWidget {
  const _TopBarBadge({
    required this.icon,
    required this.count,
    required this.tint,
    required this.tooltip,
    required this.onTap,
    this.alwaysShow = false,
  });

  final IconData icon;
  final int count;
  final Color tint;
  final String tooltip;
  final VoidCallback onTap;
  final bool alwaysShow;

  @override
  Widget build(BuildContext context) {
    final showCount = count > 0;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20, color: tint),
                if (showCount)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
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
