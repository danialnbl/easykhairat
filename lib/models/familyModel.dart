class FamilyModel {
  final int? familyId;
  final String familymemberName;
  final String familymemberIdentification;
  final String familymemberRelationship;
  final DateTime familyCreatedAt;
  final DateTime familyUpdatedAt; // Added this field
  final String userId;

  FamilyModel({
    this.familyId,
    required this.familymemberName,
    required this.familymemberIdentification,
    required this.familymemberRelationship,
    required this.familyCreatedAt,
    required this.familyUpdatedAt, // Added this field
    required this.userId,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      familyId: json['family_id'],
      familymemberName: json['familymember_name'],
      familymemberIdentification: json['familymember_identification'],
      familymemberRelationship: json['familymember_relationship'],
      familyCreatedAt: DateTime.parse(json['family_created_at']),
      familyUpdatedAt: DateTime.parse(
        json['family_updated_at'],
      ), // Added this field
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'familymember_name': familymemberName,
      'familymember_identification': familymemberIdentification,
      'familymember_relationship': familymemberRelationship,
      'family_created_at': familyCreatedAt.toIso8601String(),
      'family_updated_at':
          familyUpdatedAt.toIso8601String(), // Added this field
      'user_id': userId,
    };

    if (familyId != null) {
      data['family_id'] = familyId.toString();
    }

    return data;
  }

  FamilyModel copyWith({
    int? familyId,
    String? familymemberName,
    String? familymemberIdentification,
    String? familymemberRelationship,
    DateTime? familyCreatedAt,
    DateTime? familyUpdatedAt, // Added this field
    String? userId,
  }) {
    return FamilyModel(
      familyId: familyId ?? this.familyId,
      familymemberName: familymemberName ?? this.familymemberName,
      familymemberIdentification:
          familymemberIdentification ?? this.familymemberIdentification,
      familymemberRelationship:
          familymemberRelationship ?? this.familymemberRelationship,
      familyCreatedAt: familyCreatedAt ?? this.familyCreatedAt,
      familyUpdatedAt:
          familyUpdatedAt ?? this.familyUpdatedAt, // Added this field
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'FamilyModel(familyId: $familyId, familymemberName: $familymemberName, familymemberIdentification: $familymemberIdentification, familymemberRelationship: $familymemberRelationship, familyCreatedAt: $familyCreatedAt, familyUpdatedAt: $familyUpdatedAt, userId: $userId)';
  }
}
