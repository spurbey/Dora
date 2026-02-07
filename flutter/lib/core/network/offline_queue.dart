class OfflineQueue {
  Future<void> enqueue(String requestId, String payload) async {
    // Stub: implement persistence + sync in Phase 2.
  }

  Future<void> flush() async {
    // Stub: replay queued requests when online.
  }
}
