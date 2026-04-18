import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/features/create/data/trip_repository.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora_api/dora_api.dart' as openapi;

final liveHubActiveSessionProvider =
    StreamProvider.autoDispose<LiveHubActiveSession?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.id;
  if (userId == null || userId.isEmpty) {
    return Stream<LiveHubActiveSession?>.value(null);
  }
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT s.trip_local_id AS trip_id, s.control_state AS state,
           s.updated_at AS local_updated_at, t.name
    FROM session_journal s
    INNER JOIN trips t ON t.id = s.trip_local_id
    WHERE t.user_id = ?
      AND s.control_state IN ('active', 'paused')
    ORDER BY s.updated_at DESC
    LIMIT 1
    ''',
    variables: [Variable<String>(userId)],
    readsFrom: {db.sessionJournal, db.trips},
  );
  return query.watchSingleOrNull().map((row) {
    if (row == null) {
      return null;
    }
    return LiveHubActiveSession(
      tripId: row.read<String>('trip_id'),
      tripName: row.read<String>('name'),
      state: row.read<String>('state'),
      updatedAt: row.read<DateTime>('local_updated_at'),
    );
  });
});

class LiveHubScreen extends ConsumerStatefulWidget {
  const LiveHubScreen({super.key});

  @override
  ConsumerState<LiveHubScreen> createState() => _LiveHubScreenState();
}

class _LiveHubScreenState extends ConsumerState<LiveHubScreen> {
  bool _redirected = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<LiveHubActiveSession?>>(
      liveHubActiveSessionProvider,
      (_, next) {
        if (_redirected) return;
        next.whenData((session) {
          if (session != null && mounted) {
            _redirected = true;
            context.go(Routes.liveCapturePath(session.tripId));
          }
        });
      },
    );

    final activeSessionAsync = ref.watch(liveHubActiveSessionProvider);

    return Scaffold(
      body: SafeArea(
        child: activeSessionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(
              'Unable to check live session state.',
              style: AppTypography.body.copyWith(color: AppColors.error),
            ),
          ),
          data: (session) {
            if (session != null) {
              return const Center(child: CircularProgressIndicator());
            }
            return const _LiveTripCreationView();
          },
        ),
      ),
    );
  }
}

class _LiveTripCreationView extends ConsumerStatefulWidget {
  const _LiveTripCreationView();

  @override
  ConsumerState<_LiveTripCreationView> createState() =>
      _LiveTripCreationViewState();
}

class _LiveTripCreationViewState extends ConsumerState<_LiveTripCreationView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  List<String> _activityFocus = [];
  List<String> _travelStyle = [];
  String? _budgetCategory;
  bool _submitting = false;

  static const _activityOptions = [
    'Hiking',
    'Food',
    'Photography',
    'Nightlife',
    'Beaches',
    'Cultural',
    'Adventure',
    'Relaxation',
  ];

  static const _styleOptions = [
    'Adventure',
    'Luxury',
    'Budget',
    'Cultural',
    'Relaxed',
  ];

  static const _budgetOptions = ['budget', 'mid-range', 'luxury'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _activityFocus.isNotEmpty &&
      !_submitting;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_activityFocus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one activity focus')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repository = ref.read(tripRepositoryProvider);
      final trip = await repository.createTrip(
        name: _nameController.text.trim(),
        activityFocus: _activityFocus.map((s) => s.toLowerCase()).toList(),
        travelStyle: _travelStyle.isNotEmpty
            ? _travelStyle.map((s) => s.toLowerCase()).toList()
            : null,
        budgetCategory: _budgetCategory,
      );

      if (!mounted) return;

      await _maybeCollectUserMetadata();

      if (!mounted) return;
      context.go(Routes.liveCapturePath(trip.id));
    } on TripIdentityException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), duration: const Duration(seconds: 4)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create trip: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _maybeCollectUserMetadata() async {
    try {
      final authService = ref.read(authServiceProvider);
      final token = await authService.getAccessToken();
      if (token == null || token.isEmpty) return;
      final auth = 'Bearer $token';

      final usersApi = ref.read(usersApiProvider);
      final resp = await usersApi.getUserMetadataApiV1UsersMeMetadataGet(
        authorization: auth,
      );
      final meta = resp.data;
      if (meta == null) return;

      final isEmpty = (meta.dietaryRestrictions?.isEmpty ?? true) &&
          (meta.preferredTravelStyle?.isEmpty ?? true) &&
          (meta.dislikes?.isEmpty ?? true) &&
          meta.budgetRange == null;

      if (!isEmpty || !mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _UserPreferencesSheet(
          onSubmit: (dietary, dislikes, style) async {
            try {
              final payload = openapi.UserMetadataUpdate((b) {
                if (dietary.isNotEmpty) b.dietaryRestrictions.replace(dietary);
                if (dislikes.isNotEmpty) b.dislikes.replace(dislikes);
                if (style.isNotEmpty) b.preferredTravelStyle.replace(style);
              });
              await usersApi.upsertUserMetadataApiV1UsersMeMetadataPut(
                authorization: auth,
                userMetadataUpdate: payload,
              );
            } catch (_) {}
          },
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.allMd,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Icon(
          Icons.explore_outlined,
          size: 48,
          color: AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Start your journey',
          style: AppTypography.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Create a live trip and Dora will guide you along the way.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Trip name',
                  hintText: 'e.g., Summer in Japan',
                  border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Trip name is required' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('What are you into?', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Select at least one activity focus',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _activityOptions.map((option) {
                  final selected = _activityFocus.contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _activityFocus.add(option);
                        } else {
                          _activityFocus.remove(option);
                        }
                      });
                    },
                    selectedColor: AppColors.accentSoft,
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Travel style', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Optional',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _styleOptions.map((option) {
                  final selected = _travelStyle.contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _travelStyle.add(option);
                        } else {
                          _travelStyle.remove(option);
                        }
                      });
                    },
                    selectedColor: AppColors.accentSoft,
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Budget', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Optional',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _budgetOptions.map((option) {
                  final selected = _budgetCategory == option;
                  return ChoiceChip(
                    label: Text(option[0].toUpperCase() + option.substring(1)),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        _budgetCategory = val ? option : null;
                      });
                    },
                    selectedColor: AppColors.accentSoft,
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canSubmit ? _submit : null,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_submitting ? 'Creating...' : 'Start Live Trip'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserPreferencesSheet extends StatefulWidget {
  const _UserPreferencesSheet({required this.onSubmit});

  final Future<void> Function(
    List<String> dietary,
    List<String> dislikes,
    List<String> style,
  ) onSubmit;

  @override
  State<_UserPreferencesSheet> createState() => _UserPreferencesSheetState();
}

class _UserPreferencesSheetState extends State<_UserPreferencesSheet> {
  final _selectedDietary = <String>[];
  final _selectedStyle = <String>[];
  final _dislikesController = TextEditingController();
  bool _saving = false;

  static const _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Halal',
    'Kosher',
    'Gluten-free',
  ];

  static const _styleOptions = [
    'Adventure',
    'Luxury',
    'Budget',
    'Cultural',
    'Relaxed',
  ];

  @override
  void dispose() {
    _dislikesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quick preferences', style: AppTypography.h2),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Skip'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Help Dora personalize your trip advisories.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Dietary restrictions', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _dietaryOptions.map((opt) {
              final selected = _selectedDietary.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    val ? _selectedDietary.add(opt) : _selectedDietary.remove(opt);
                  });
                },
                selectedColor: AppColors.accentSoft,
                checkmarkColor: AppColors.accent,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Travel style preference', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _styleOptions.map((opt) {
              final selected = _selectedStyle.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    val ? _selectedStyle.add(opt) : _selectedStyle.remove(opt);
                  });
                },
                selectedColor: AppColors.accentSoft,
                checkmarkColor: AppColors.accent,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _dislikesController,
            decoration: InputDecoration(
              labelText: 'Things you dislike',
              hintText: 'e.g., crowded places, seafood',
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      final dislikes = _dislikesController.text
                          .split(',')
                          .map((s) => s.trim().toLowerCase())
                          .where((s) => s.isNotEmpty)
                          .toList();
                      await widget.onSubmit(
                        _selectedDietary.map((s) => s.toLowerCase()).toList(),
                        dislikes,
                        _selectedStyle.map((s) => s.toLowerCase()).toList(),
                      );
                      if (mounted) Navigator.of(context).pop();
                    },
              child: Text(_saving ? 'Saving...' : 'Save preferences'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class LiveHubActiveSession {
  const LiveHubActiveSession({
    required this.tripId,
    required this.tripName,
    required this.state,
    required this.updatedAt,
  });

  final String tripId;
  final String tripName;
  final String state;
  final DateTime updatedAt;
}
