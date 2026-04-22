import 'package:dora/core/storage/daos/v2/route_segment_claim_local_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

class V2RouteSegmentClaimRepository {
  const V2RouteSegmentClaimRepository({
    required RouteSegmentClaimLocalDao claimDao,
  }) : _claimDao = claimDao;

  final RouteSegmentClaimLocalDao _claimDao;

  Stream<Set<String>> watchClaimedSegmentKeys(String tripId) =>
      _claimDao.watchClaimedSegmentKeysForTrip(tripId);

  Future<Set<String>> listClaimedSegmentKeys(String tripId) =>
      _claimDao.listClaimedSegmentKeysForTrip(tripId);

  Future<void> replaceClaimsForTrip({
    required String tripId,
    required List<RouteSegmentClaimLocalCompanion> claims,
  }) =>
      _claimDao.replaceClaimsForTrip(
        tripLocalId: tripId,
        rows: claims,
      );
}
