class ClaimModel {
  final int? claimId; // Made nullable to handle Supabase auto-generation
  final String claimOverallStatus;
  final DateTime claimCreatedAt;
  final DateTime claimUpdatedAt;
  final int? familyId; // Made nullable
  final String? userId; // Made nullable
  final String? claimType; // Added nullable claimType

  ClaimModel({
    this.claimId, // Made optional
    required this.claimOverallStatus,
    required this.claimCreatedAt,
    required this.claimUpdatedAt,
    this.familyId, // Made optional
    this.userId, // Made optional
    this.claimType, // Added to constructor
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      claimId: json['claim_id'], // Nullable for Supabase auto-generation
      claimOverallStatus: json['claim_overallStatus'],
      claimCreatedAt: DateTime.parse(json['claim_created_at']),
      claimUpdatedAt: DateTime.parse(json['claim_updated_at']),
      familyId: json['family_id'], // Made nullable
      userId: json['user_id'], // Made nullable
      claimType: json['claim_type'], // Added to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (claimId != null) 'claim_id': claimId, // Include only if not null
      'claim_overallStatus': claimOverallStatus,
      'claim_created_at': claimCreatedAt.toIso8601String(),
      'claim_updated_at': claimUpdatedAt.toIso8601String(),
      if (familyId != null) 'family_id': familyId, // Include only if not null
      'user_id': userId, // Made nullable
      'claim_type': claimType, // Added to toJson
    };
  }

  @override
  String toString() {
    return 'ClaimModel(claimId: $claimId, overallStatus: $claimOverallStatus, userId: $userId, familyId: $familyId, claimType: $claimType)'; // Updated toString
  }
}
