import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';

/// Counter event types. Names match the `EVENT_TYPE_TO_COUNTER` map in
/// `functions/src/lib/content.ts` — `aggregateEvents` folds these into each
/// content doc's `counters` map every 5 minutes (Architecture §8, FR-9.10).
enum ContentEventType { view, download, share, play }

/// Write-only client feed into `events/` (Architecture §6.2, §7). Clients
/// never touch `counters` directly — that's a hot, contended field — they
/// append cheap throwaway events here and a Function aggregates. Rules allow
/// create-only for signed-in users; no read/update/delete.
class EventsRepository {
  EventsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Records one engagement event. Fire-and-forget at call sites — a failed
  /// counter event must never block or surface in the user-facing flow.
  Future<void> record({
    required String collection,
    required String itemId,
    required ContentEventType type,
  }) {
    return _firestore.collection(FirestoreCollections.events).add({
      'collection': collection,
      'itemId': itemId,
      'type': type.name,
      'createdAt': DateTime.now(),
    });
  }
}
