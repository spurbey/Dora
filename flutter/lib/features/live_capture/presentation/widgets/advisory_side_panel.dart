import 'dart:async';

import 'package:dora_api/dora_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/advisory/presentation/widgets/dora_avatar.dart';
import 'package:dora/features/advisory/providers/advisory_providers.dart';

const double _panelWidth = 340;
const double _compactBreakpoint = 400;

/// Slidable right-edge panel showing the Dora conversation thread.
///
/// Scrollable feed of Dora advisories + user messages + system notes,
/// with a text input pinned at the bottom. On small screens, expands to
/// full width for better mobile ergonomics.
class AdvisorySidePanel extends ConsumerStatefulWidget {
  const AdvisorySidePanel({
    super.key,
    required this.localTripId,
    required this.isOpen,
    required this.onClose,
    this.focusedAdvisoryId,
    this.onOpenAdvisoryDetail,
  });

  final String localTripId;
  final bool isOpen;
  final VoidCallback onClose;
  final String? focusedAdvisoryId;
  final void Function(AdvisoryInsightResponse)? onOpenAdvisoryDetail;

  @override
  ConsumerState<AdvisorySidePanel> createState() => _AdvisorySidePanelState();
}

class _AdvisorySidePanelState extends ConsumerState<AdvisorySidePanel> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  Timer? _pollTimer;
  bool _sending = false;
  String? _pendingUserText;
  bool _hasScrolledToFocus = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    if (widget.isOpen) {
      _startPolling();
    }
  }

  @override
  void didUpdateWidget(AdvisorySidePanel old) {
    super.didUpdateWidget(old);
    if (widget.isOpen && !old.isOpen) {
      _startPolling();
      _hasScrolledToFocus = false;
    } else if (!widget.isOpen && old.isOpen) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted || !widget.isOpen) return;
      ref.invalidate(conversationMessagesProvider(widget.localTripId));
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _pendingUserText = text;
    });
    _controller.clear();

    final notifier =
        ref.read(conversationSendNotifierProvider(widget.localTripId).notifier);
    final resp = await notifier.send(text);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _pendingUserText = null;
    });
    if (resp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't send — check connection")),
      );
    }
  }

  Future<void> _answerQuestion(String questionId, String answer) async {
    setState(() => _sending = true);
    final notifier =
        ref.read(conversationSendNotifierProvider(widget.localTripId).notifier);
    await notifier.answer(questionId, answer);
    if (!mounted) return;
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth < _compactBreakpoint ? screenWidth : _panelWidth;

    return IgnorePointer(
      ignoring: !widget.isOpen,
      child: Stack(
        children: [
          // Backdrop (tap to close)
          AnimatedOpacity(
            opacity: widget.isOpen ? 1 : 0,
            duration: AnimationTokens.normal,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                color: Colors.black.withValues(alpha: 0.32),
              ),
            ),
          ),
          // Sliding panel
          AnimatedPositioned(
            duration: AnimationTokens.slow,
            curve: Curves.easeOutCubic,
            right: widget.isOpen ? 0 : -width,
            top: 0,
            bottom: 0,
            width: width,
            child: Material(
              elevation: 0,
              color: AppColors.surface,
              child: SafeArea(
                child: Column(
                  children: [
                    _SidePanelHeader(
                      onClose: widget.onClose,
                      statusHint: _statusHint(),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    Expanded(
                      child: _buildThread(),
                    ),
                    _PendingQuestionChips(
                      localTripId: widget.localTripId,
                      onAnswer: _answerQuestion,
                      disabled: _sending,
                    ),
                    _InputBar(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSend: _send,
                      sending: _sending,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusHint() {
    if (_sending) return 'Dora is thinking…';
    return 'Your explorer guide';
  }

  Widget _buildThread() {
    final asyncMessages =
        ref.watch(conversationMessagesProvider(widget.localTripId));

    return asyncMessages.when(
      loading: () => const _ThreadSkeleton(),
      error: (e, _) => _ThreadError(
        onRetry: () =>
            ref.invalidate(conversationMessagesProvider(widget.localTripId)),
      ),
      data: (list) {
        final messages = list.messages.toList();
        if (_pendingUserText != null) {
          // Optimistic append (keyed with a sentinel id)
          messages.add(_optimisticUserMessage(_pendingUserText!));
        }

        if (messages.isEmpty) {
          return _ThreadEmpty();
        }

        // Auto-scroll to bottom when new content arrives
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: AnimationTokens.normal,
            curve: Curves.easeOutCubic,
          );
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final prev = index > 0 ? messages[index - 1] : null;
            final showTimestamp =
                prev == null || _shouldShowTimestampBetween(prev, msg);
            final isFocused = widget.focusedAdvisoryId != null &&
                msg.advisoryId?.toString() == widget.focusedAdvisoryId;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showTimestamp)
                  _TimestampDivider(time: msg.createdAt),
                _ConversationBubble(
                  message: msg,
                  highlighted: isFocused,
                  onOpenAdvisoryDetail: widget.onOpenAdvisoryDetail,
                  onAnswerOption: (option) =>
                      _answerQuestion(msg.id.toString(), option),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
            );
          },
        );
      },
    );
  }

  bool _shouldShowTimestampBetween(
    ConversationMessageResponse prev,
    ConversationMessageResponse curr,
  ) {
    final gap = curr.createdAt.difference(prev.createdAt).inMinutes;
    return gap >= 30;
  }
}

ConversationMessageResponse _optimisticUserMessage(String content) {
  // Build a placeholder response object. We use fromJson to avoid relying on
  // built_value builders for a non-persisted value.
  return ConversationMessageResponse(
    (b) => b
      ..id = '00000000-0000-0000-0000-000000000000'
      ..tripId = '00000000-0000-0000-0000-000000000000'
      ..userId = '00000000-0000-0000-0000-000000000000'
      ..role = 'user'
      ..messageType = 'user_query'
      ..content = content
      ..createdAt = DateTime.now().toUtc(),
  );
}

// ────────────────────────────────────────────────────────────────────
// Header
// ────────────────────────────────────────────────────────────────────

class _SidePanelHeader extends StatelessWidget {
  const _SidePanelHeader({required this.onClose, required this.statusHint});

  final VoidCallback onClose;
  final String statusHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          const DoraAvatar(size: 44, showPulse: true),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Dora', style: AppTypography.h2),
                const SizedBox(height: 2),
                Text(
                  statusHint,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Thread states
// ────────────────────────────────────────────────────────────────────

class _ThreadSkeleton extends StatelessWidget {
  const _ThreadSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.borderMd,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadError extends StatelessWidget {
  const _ThreadError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, color: AppColors.textSecondary, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Dora couldn't load messages",
            style: AppTypography.body
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ThreadEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DoraAvatar(size: 64, showPulse: true),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Hi, I\'m Dora 👋',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ask me about food, places, safety — anything you want to know on your trip.',
              style: AppTypography.body
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Timestamp divider
// ────────────────────────────────────────────────────────────────────

class _TimestampDivider extends StatelessWidget {
  const _TimestampDivider({required this.time});
  final DateTime time;

  String _format(DateTime t) {
    final local = t.toLocal();
    final now = DateTime.now();
    final sameDay = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    if (sameDay) return 'Today $hh:$mm';
    return '${local.month}/${local.day} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Text(
          _format(time),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Conversation bubble (handles all message types)
// ────────────────────────────────────────────────────────────────────

class _ConversationBubble extends ConsumerWidget {
  const _ConversationBubble({
    required this.message,
    this.highlighted = false,
    this.onOpenAdvisoryDetail,
    this.onAnswerOption,
  });

  final ConversationMessageResponse message;
  final bool highlighted;
  final void Function(AdvisoryInsightResponse)? onOpenAdvisoryDetail;
  final void Function(String option)? onAnswerOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (message.role) {
      case 'user':
        return _UserBubble(content: message.content ?? '');
      case 'system':
        return _SystemNote(text: message.content ?? '');
      case 'dora':
      default:
        return _DoraBubble(
          message: message,
          highlighted: highlighted,
          onOpenAdvisoryDetail: onOpenAdvisoryDetail,
          onAnswerOption: onAnswerOption,
        );
    }
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            content,
            style: AppTypography.body.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _SystemNote extends StatelessWidget {
  const _SystemNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Center(
        child: Text(
          text,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _DoraBubble extends StatelessWidget {
  const _DoraBubble({
    required this.message,
    this.highlighted = false,
    this.onOpenAdvisoryDetail,
    this.onAnswerOption,
  });

  final ConversationMessageResponse message;
  final bool highlighted;
  final void Function(AdvisoryInsightResponse)? onOpenAdvisoryDetail;
  final void Function(String option)? onAnswerOption;

  @override
  Widget build(BuildContext context) {
    final isClarifying = message.messageType == 'clarifying_question';
    final isAdvisory = message.messageType == 'advisory_suggestion';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DoraAvatar(size: 28),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AnimatedContainer(
            duration: AnimationTokens.slow,
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: highlighted ? AppColors.accentSoft : AppColors.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: highlighted
                    ? AppColors.accent.withValues(alpha: 0.4)
                    : AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
            child: isAdvisory
                ? _AdvisorySuggestionContent(
                    message: message,
                    onOpenAdvisoryDetail: onOpenAdvisoryDetail,
                  )
                : isClarifying
                    ? _ClarifyingQuestionContent(
                        message: message,
                        onAnswerOption: onAnswerOption,
                      )
                    : _PlainText(content: message.content ?? ''),
          ),
        ),
      ],
    );
  }
}

class _PlainText extends StatelessWidget {
  const _PlainText({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _AdvisorySuggestionContent extends StatelessWidget {
  const _AdvisorySuggestionContent({
    required this.message,
    this.onOpenAdvisoryDetail,
  });

  final ConversationMessageResponse message;
  final void Function(AdvisoryInsightResponse)? onOpenAdvisoryDetail;

  @override
  Widget build(BuildContext context) {
    final meta = message.messageMetadata?.asMap ?? <dynamic, dynamic>{};
    final category = meta['category']?.toString();
    final title = meta['title']?.toString() ?? 'Tip';
    final placeName = meta['place_name']?.toString();
    final body = message.content ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CategoryTag(category: category),
            const Spacer(),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          placeName?.trim().isNotEmpty == true ? placeName! : title,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
        if (onOpenAdvisoryDetail != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Tap for details →',
              style: AppTypography.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.category});
  final String? category;

  static const Map<String, (String, String, Color)> _map = {
    'safety_warning': ('⚠️', 'Safety', Color(0xFFF59E0B)),
    'scam_alert': ('🚨', 'Scam Alert', Color(0xFFDC2626)),
    'food_tip': ('🍜', 'Food', Color(0xFFEA580C)),
    'photo_spot': ('📸', 'Photo Spot', Color(0xFF7C3AED)),
    'transport_tip': ('🚌', 'Transport', Color(0xFF2563EB)),
    'accommodation': ('🏨', 'Stay', Color(0xFF0891B2)),
    'cultural_etiquette': ('🙏', 'Culture', Color(0xFF7C3AED)),
    'must_do': ('🎯', 'Must Do', Color(0xFF059669)),
    'avoid': ('🚫', 'Avoid', Color(0xFFDC2626)),
    'general_tip': ('💡', 'Tip', AppColors.accent),
  };

  @override
  Widget build(BuildContext context) {
    final tuple = _map[category ?? 'general_tip'] ?? _map['general_tip']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tuple.$3.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tuple.$1, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            tuple.$2,
            style: AppTypography.caption.copyWith(
              color: tuple.$3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClarifyingQuestionContent extends StatelessWidget {
  const _ClarifyingQuestionContent({
    required this.message,
    this.onAnswerOption,
  });

  final ConversationMessageResponse message;
  final void Function(String option)? onAnswerOption;

  @override
  Widget build(BuildContext context) {
    final meta = message.messageMetadata?.asMap ?? <dynamic, dynamic>{};
    final optionsRaw = meta['options'];
    final options = <String>[];
    if (optionsRaw is List) {
      for (final o in optionsRaw) {
        options.add(o.toString());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.content ?? '',
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        ),
        if (options.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final opt in options)
                ActionChip(
                  label: Text(opt),
                  onPressed: () => onAnswerOption?.call(opt),
                  backgroundColor: AppColors.accentSoft,
                  labelStyle: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Pending question chips (shown above input when a clarify is open)
// ────────────────────────────────────────────────────────────────────

class _PendingQuestionChips extends ConsumerWidget {
  const _PendingQuestionChips({
    required this.localTripId,
    required this.onAnswer,
    required this.disabled,
  });

  final String localTripId;
  final Future<void> Function(String questionId, String answer) onAnswer;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(pendingClarifyingQuestionProvider(localTripId));
    final question = async.asData?.value;
    if (question == null) return const SizedBox.shrink();

    final meta = question.messageMetadata?.asMap ?? <dynamic, dynamic>{};
    final optionsRaw = meta['options'];
    final options = <String>[];
    if (optionsRaw is List) {
      for (final o in optionsRaw) {
        options.add(o.toString());
      }
    }
    if (options.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final opt in options)
            ActionChip(
              label: Text(opt),
              onPressed: disabled
                  ? null
                  : () => onAnswer(question.id.toString(), opt),
              backgroundColor: AppColors.accentSoft,
              labelStyle: AppTypography.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Input bar
// ────────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.sending,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Ask Dora anything…',
                    hintStyle: AppTypography.body
                        .copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: AnimationTokens.fast,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasText && !sending
                    ? AppColors.accent
                    : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: hasText && !sending ? onSend : null,
                  child: Icon(
                    sending ? Icons.hourglass_top : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
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
