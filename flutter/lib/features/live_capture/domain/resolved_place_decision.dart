class ResolvedPlaceDecision {
  const ResolvedPlaceDecision({
    required this.state,
    required this.confidence,
    required this.reasonCode,
    this.placeId,
    this.hintJson,
  });

  final String state;
  final double confidence;
  final String reasonCode;
  final String? placeId;
  final String? hintJson;
}

