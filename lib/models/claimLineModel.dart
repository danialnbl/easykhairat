class ClaimLineModel {
  final int? claimLineId;
  final String claimLineReason;
  final String claimLineStatus;
  final double claimLineTotalPrice;
  final DateTime claimLineCreatedAt;
  final DateTime claimLineUpdatedAt;
  final int? claimId;

  ClaimLineModel({
    this.claimLineId,
    required this.claimLineReason,
    required this.claimLineStatus,
    required this.claimLineTotalPrice,
    required this.claimLineCreatedAt,
    required this.claimLineUpdatedAt,
    this.claimId,
  });

  factory ClaimLineModel.fromJson(Map<String, dynamic> json) {
    return ClaimLineModel(
      claimLineId: json['claimLine_id'],
      claimLineReason: json['claimLine_reason'],
      claimLineStatus: json['claimLine_status'],
      claimLineTotalPrice: json['claimLine_totalPrice'].toDouble(),
      claimLineCreatedAt: DateTime.parse(json['claimLine_created_at']),
      claimLineUpdatedAt: DateTime.parse(json['claimLine_updated_at']),
      claimId: json['claim_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (claimLineId != null) 'claimLine_id': claimLineId,
      'claimLine_reason': claimLineReason,
      'claimLine_status': claimLineStatus,
      'claimLine_totalPrice': claimLineTotalPrice,
      'claimLine_created_at': claimLineCreatedAt.toIso8601String(),
      'claimLine_updated_at': claimLineUpdatedAt.toIso8601String(),
      if (claimId != null) 'claim_id': claimId,
    };
  }

  @override
  String toString() {
    return 'ClaimLineModel(claimLineId: $claimLineId, reason: $claimLineReason, status: $claimLineStatus, totalPrice: $claimLineTotalPrice, claimId: $claimId)';
  }
}
