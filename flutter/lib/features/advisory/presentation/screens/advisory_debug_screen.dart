import 'dart:async';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_radius.dart';
// AdvisoryRepository used via providers, not directly imported here.
import 'package:dora/features/advisory/data/models/advisory_brain_state.dart';
import 'package:dora/features/advisory/providers/advisory_providers.dart';
import 'package:dora_api/dora_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal debug screen to exercise the full advisory backend round-trip.
///
/// Gated by [FeatureFlags.enableAdvisoryPipeline]. Accessed from the trip
/// editor overflow menu. Shows brain state, insights inbox, jobs list, and
/// quick action buttons. Auto-refreshes every 30s.
class AdvisoryDebugScreen extends ConsumerStatefulWidget {
  const AdvisoryDebugScreen({
    required this.tripId,
    this.tripTitle,
    super.key,
  });

  final String tripId;
  final String? tripTitle;

  @override
  ConsumerState<AdvisoryDebugScreen> createState() =>
      _AdvisoryDebugScreenState();
}

class _AdvisoryDebugScreenState extends ConsumerState<AdvisoryDebugScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshAll();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshAll() {
    ref.invalidate(advisoryBrainStateProvider(widget.tripId));
    ref.invalidate(advisoryInsightsProvider(widget.tripId));
    ref.invalidate(advisoryJobsProvider(widget.tripId));
  }

  @override
  Widget build(BuildContext context) {
    final brainAsync = ref.watch(advisoryBrainStateProvider(widget.tripId));
    final insightsAsync = ref.watch(advisoryInsightsProvider(widget.tripId));
    final jobsAsync = ref.watch(advisoryJobsProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Advisory Debug${widget.tripTitle != null ? " - ${widget.tripTitle}" : ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Brain state
          _BrainStateCard(
            tripId: widget.tripId,
            brainAsync: brainAsync,
            onPause: () => _pause(),
            onResume: () => _resume(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Quick actions
          _QuickActionsCard(
            onStartPreTrip: () => _startPreTrip(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Insights
          _SectionHeader('Insights (inbox)'),
          const SizedBox(height: AppSpacing.sm),
          insightsAsync.when(
            data: (resp) {
              final insights = resp.insights?.toList() ?? [];
              if (insights.isEmpty) {
                return const _EmptyState('No insights yet');
              }
              return Column(
                children: insights
                    .map((i) => _InsightCard(
                          insight: i,
                          tripId: widget.tripId,
                        ))
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorCard(e.toString()),
          ),
          const SizedBox(height: AppSpacing.md),

          // Jobs
          _SectionHeader('Jobs'),
          const SizedBox(height: AppSpacing.sm),
          jobsAsync.when(
            data: (resp) {
              final jobs = resp.jobs?.toList() ?? [];
              if (jobs.isEmpty) {
                return const _EmptyState('No jobs yet');
              }
              return Column(
                children: jobs.map((j) => _JobCard(job: j)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorCard(e.toString()),
          ),
        ],
      ),
    );
  }

  /// Resolve the server trip ID from the local Drift ID.
  /// Uses the cached provider so it only hits the network once per session.
  Future<String> _serverTripId() async {
    return ref.read(serverTripIdProvider(widget.tripId).future);
  }

  Future<void> _startPreTrip() async {
    try {
      final serverId = await _serverTripId();
      final repo = ref.read(advisoryRepositoryProvider);
      await repo.startAdvisory(serverId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pre-trip advisory job queued')),
        );
      }
      _refreshAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pause() async {
    try {
      final serverId = await _serverTripId();
      await ref.read(advisoryRepositoryProvider).pauseAdvisory(serverId);
      _refreshAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pause error: $e')),
        );
      }
    }
  }

  Future<void> _resume() async {
    try {
      final serverId = await _serverTripId();
      await ref.read(advisoryRepositoryProvider).resumeAdvisory(serverId);
      _refreshAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resume error: $e')),
        );
      }
    }
  }
}

// ─── Widgets ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(message,
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(message, style: const TextStyle(color: Colors.red)),
        ),
      );
}

class _BrainStateCard extends StatelessWidget {
  const _BrainStateCard({
    required this.tripId,
    required this.brainAsync,
    required this.onPause,
    required this.onResume,
  });

  final String tripId;
  final AsyncValue<AdvisoryBrainState> brainAsync;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: brainAsync.when(
          data: (brain) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Brain State',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _kvRow('lifecycle', brain.lifecycleState),
              _kvRow('trip_class', brain.tripClass),
              _kvRow('cadence', '${brain.cadenceSeconds}s'),
              _kvRow('mode', brain.mode),
              _kvRow('ignore_streak', '${brain.ignoreStreak}'),
              _kvRow('localities', '${brain.advisedLocalitiesCount}'),
              _kvRow('pois', '${brain.advisedPoisCount}'),
              _kvRow('next_eligible',
                  brain.nextEligibleAt?.toLocal().toString() ?? '-'),
              if (brain.pausedReason != null)
                _kvRow('paused_reason', brain.pausedReason!),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (brain.isActive)
                    FilledButton.tonal(
                      onPressed: onPause,
                      child: const Text('Pause'),
                    ),
                  if (brain.isPaused) ...[
                    FilledButton(
                      onPressed: onResume,
                      child: const Text('Resume'),
                    ),
                  ],
                ],
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Brain state unavailable: $e',
              style: const TextStyle(color: Colors.orange)),
        ),
      ),
    );
  }

  Widget _kvRow(String key, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
                width: 120,
                child: Text(key,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.onStartPreTrip});
  final VoidCallback onStartPreTrip;

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Actions',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: onStartPreTrip,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Pre-Trip Advisory'),
              ),
            ],
          ),
        ),
      );
}

const _categoryEmoji = {
  'food_tip': '🍽️',
  'scam_alert': '⚠️',
  'safety_warning': '🚨',
  'photo_spot': '📸',
  'transport_tip': '🚗',
  'accommodation': '🏨',
  'cultural_etiquette': '🙏',
  'must_do': '⭐',
  'avoid': '🚫',
  'general_tip': '💡',
};

class _InsightCard extends ConsumerWidget {
  const _InsightCard({required this.insight, required this.tripId});
  final AdvisoryInsightResponse insight;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catName = insight.category.name;
    final emoji = _categoryEmoji[catName] ?? '💡';
    final actionNotifier =
        ref.watch(advisoryActionNotifierProvider(tripId).notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    insight.placeName ?? catName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    catName,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(insight.body,
                maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'confidence: ${insight.confidenceScore.toStringAsFixed(2)}  |  status: ${insight.status.name}',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _ActionButton(
                  label: 'Accept',
                  icon: Icons.thumb_up_alt_outlined,
                  onTap: () => actionNotifier.recordAction(
                      insight.id, UserActionType.liked),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ActionButton(
                  label: 'Dismiss',
                  icon: Icons.close,
                  onTap: () => actionNotifier.recordAction(
                      insight.id, UserActionType.dismissed),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ActionButton(
                  label: 'Save',
                  icon: Icons.bookmark_outline,
                  onTap: () => actionNotifier.recordAction(
                      insight.id, UserActionType.saved),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          minimumSize: Size.zero,
        ),
      );
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final AdvisoryJobResponse job;

  @override
  Widget build(BuildContext context) {
    final statusName = job.status.name;
    final statusColor = switch (statusName) {
      'completed' => Colors.green,
      'processing' => Colors.blue,
      'queued' => Colors.orange,
      'failed' => Colors.red,
      _ => Colors.grey,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.work_outline, color: statusColor, size: 20),
        title: Text(job.jobType.name,
            style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          '$statusName | stage: ${job.stage?.name ?? "-"}',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Text(
          _timeAgo(job.createdAt),
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
