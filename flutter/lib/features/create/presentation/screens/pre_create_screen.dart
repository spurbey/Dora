import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_shadows.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/shared/widgets/confirmation_dialog.dart';
import 'package:dora/shared/widgets/date_picker_field.dart';
import 'package:dora/shared/widgets/tag_selector.dart';

class PreCreateScreen extends ConsumerStatefulWidget {
  const PreCreateScreen({super.key});

  @override
  ConsumerState<PreCreateScreen> createState() => _PreCreateScreenState();
}

class _PreCreateScreenState extends ConsumerState<PreCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _tags = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _nameController.text.trim().isNotEmpty ||
      _descriptionController.text.trim().isNotEmpty ||
      _startDate != null ||
      _endDate != null ||
      _tags.isNotEmpty;

  bool get _isValidDateRange {
    if (_startDate == null || _endDate == null) {
      return true;
    }
    return _endDate!.isAfter(_startDate!) || _endDate!.isAtSameMomentAs(_startDate!);
  }

  Future<void> _handleClose() async {
    if (!_isDirty) {
      if (mounted) {
        context.go(Routes.trips);
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Discard trip?',
        message: 'Your changes will be lost.',
        confirmText: 'Discard',
        cancelText: 'Cancel',
        isDestructive: true,
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed == true && mounted) {
      context.go(Routes.trips);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_isValidDateRange) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repository = ref.read(tripRepositoryProvider);
      final trip = await repository.createTrip(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        tags: _tags,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Let's build your journey!")),
      );

      context.go(Routes.editorPath(trip.id));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF5F2EF),
                    Color(0xFFE6E1DD),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _handleClose,
                    icon: const Icon(Icons.close),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: AppSpacing.horizontalMd,
                      child: Container(
                        width: 327,
                        padding: AppSpacing.allLg,
                        decoration: BoxDecoration(
                          color: AppColors.card.withOpacity(0.95),
                          borderRadius: AppRadius.borderXl,
                          boxShadow: AppShadows.soft,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Your Journey', style: AppTypography.h2),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Trip Name',
                                  hintText: 'e.g., Summer in Japan',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Trip name required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Description (Optional)',
                                  hintText: 'Tell your story...',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text('When did you go?', style: AppTypography.caption),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: DatePickerField(
                                      label: 'Start Date',
                                      value: _startDate,
                                      onDateSelected: (date) {
                                        setState(() => _startDate = date);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: DatePickerField(
                                      label: 'End Date',
                                      value: _endDate,
                                      onDateSelected: (date) {
                                        setState(() => _endDate = date);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (!_isValidDateRange)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                                  child: Text(
                                    'End date must be after start date',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.md),
                              Text('Tags (Optional)', style: AppTypography.caption),
                              const SizedBox(height: AppSpacing.sm),
                              TagSelector(
                                selectedTags: _tags,
                                suggestions: const [
                                  'Solo',
                                  'Couple',
                                  'Family',
                                  'Adventure',
                                  'Relaxed',
                                  'Budget',
                                  'Luxury',
                                ],
                                onTagsChanged: (tags) => setState(() => _tags = tags),
                                maxTags: 5,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submitting ||
                                          _nameController.text.trim().isEmpty
                                      ? null
                                      : _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.sm,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.borderMd,
                                    ),
                                  ),
                                  child: Text(_submitting ? 'Creating...' : 'Create Trip'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
