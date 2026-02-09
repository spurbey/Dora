import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/features/create/domain/timeline_state.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';

part 'timeline_provider.g.dart';

@riverpod
TimelineState timelineState(TimelineStateRef ref, String tripId) {
  final editor = ref.watch(editorControllerProvider(tripId)).valueOrNull;
  if (editor == null) {
    return const TimelineState();
  }
  return TimelineState(
    places: editor.places,
    routes: editor.routes,
    selectedItemId: editor.selectedItemId,
    selectedItemType: editor.selectedItemType,
  );
}
