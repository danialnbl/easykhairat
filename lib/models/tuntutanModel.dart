import 'package:easykhairat/models/userModel.dart';

class ClaimModel {
  final int? claimId;
  final String claimOverallStatus;
  final DateTime claimCreatedAt;
  final DateTime claimUpdatedAt;
  final int? familyId;
  final String? userId;
  final String? claimType;
  String? claimReason;
  String? claimCertificateUrl;
  final User? user;

  ClaimModel({
    this.claimId,
    required this.claimOverallStatus,
    required this.claimCreatedAt,
    required this.claimUpdatedAt,
    this.familyId,
    this.userId,
    this.claimType,
    this.claimReason,
    this.claimCertificateUrl,
    this.user,
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
      claimReason: json['claim_reason'], // Added claim reason
      claimCertificateUrl:
          json['claim_certificate_url'], // Added certificate URL
      user: json['users'] != null ? User.fromJson(json['users']) : null,
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
      'claim_reason': claimReason, // Added claim reason to toJson
      'claim_certificate_url':
          claimCertificateUrl, // Added certificate URL to toJson
    };
  }

  @override
  String toString() {
    return 'ClaimModel(claimId: $claimId, overallStatus: $claimOverallStatus, userId: $userId, familyId: $familyId, claimType: $claimType, claimReason: $claimReason, claimCertificateUrl: $claimCertificateUrl)'; // Updated toString
  }
}
