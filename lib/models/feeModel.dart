class FeeModel {
  final int feeId;
  final String feeDescription;
  final DateTime feeDue;
  final String feeType;
  final DateTime feeCreatedAt;
  final DateTime feeUpdatedAt;
  final int adminId;
  final String userId; // Using String for UUID is fine

  FeeModel({
    required this.feeId,
    required this.feeDescription,
    required this.feeDue,
    required this.feeType,
    required this.feeCreatedAt,
    required this.feeUpdatedAt,
    required this.adminId,
    required this.userId,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      feeId: json['fee_id'],
      feeDescription: json['fee_description'],
      feeDue: DateTime.parse(json['fee_due']),
      feeType: json['fee_type'],
      feeCreatedAt: DateTime.parse(json['fee_created_at']),
      feeUpdatedAt: DateTime.parse(json['fee_updated_at']),
      adminId: json['admin_id'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fee_id': feeId,
      'fee_description': feeDescription,
      'fee_due': feeDue.toIso8601String(),
      'fee_type': feeType,
      'fee_created_at': feeCreatedAt.toIso8601String(),
      'fee_updated_at': feeUpdatedAt.toIso8601String(),
      'admin_id': adminId,
      'user_id': userId,
    };
  }
}
