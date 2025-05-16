class ClaimLineModel {
  final int? claimLineId;
  final String claimLineReason;
  final double claimLineTotalPrice;
  final DateTime claimLineCreatedAt;
  final DateTime? claimLineUpdatedAt; // Made nullable
  final int? claimId;

  ClaimLineModel({
    this.claimLineId,
    required this.claimLineReason,
    required this.claimLineTotalPrice,
    required this.claimLineCreatedAt,
    this.claimLineUpdatedAt,
    this.claimId,
  });

  factory ClaimLineModel.fromJson(Map<String, dynamic> json) {
    return ClaimLineModel(
      claimLineId: json['claimLine_id'],
      claimLineReason: json['claimLine_reason'],
      claimLineTotalPrice: json['claimLine_totalPrice'].toDouble(),
      claimLineCreatedAt: DateTime.parse(json['claimLine_created_at']),
      claimLineUpdatedAt: DateTime.parse(json['claimline_updated_at']),
      claimId: json['claim_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (claimLineId != null) 'claimLine_id': claimLineId,
      'claimLine_reason': claimLineReason,
      'claimLine_totalPrice': claimLineTotalPrice,
      'claimLine_created_at': claimLineCreatedAt.toIso8601String(),
      'claimline_updated_at': claimLineUpdatedAt?.toIso8601String(),
      if (claimId != null) 'claim_id': claimId,
    };
  }

  @override
  String toString() {
    return 'ClaimLineModel(claimLineId: $claimLineId, reason: $claimLineReason, totalPrice: $claimLineTotalPrice, claimId: $claimId)';
  }
}
