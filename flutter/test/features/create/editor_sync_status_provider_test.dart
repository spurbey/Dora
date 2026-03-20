import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';

void main() {
  group('resolveEditorSyncStatus', () {
    test('returns blocked when blocked items exist', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 1,
          failedItems: 5,
          activeItems: 10,
          unsyncedRows: 3,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.blocked);
      expect(status.label, 'Sync blocked');
    });

    test('returns failed when failed items exist without blocked', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 0,
          failedItems: 2,
          activeItems: 10,
          unsyncedRows: 3,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.failed);
      expect(status.label, 'Sync failed');
    });

    test('returns syncing when active items exist', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 0,
          failedItems: 0,
          activeItems: 4,
          unsyncedRows: 5,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.syncing);
      expect(status.label, 'Syncing...');
    });

    test('returns localSaved when unsynced rows exist without active work', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 0,
          failedItems: 0,
          activeItems: 0,
          unsyncedRows: 2,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.localSaved);
      expect(status.label, 'Saved locally');
    });

    test('returns synced when no pending or failed signals exist', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 0,
          failedItems: 0,
          activeItems: 0,
          unsyncedRows: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.synced);
      expect(status.label, 'Synced');
    });
  });
}
