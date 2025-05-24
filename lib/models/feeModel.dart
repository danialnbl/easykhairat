class FeeModel {
  final int? feeId;
  final String feeDescription;
  final DateTime feeDue;
  final String feeType;
  final DateTime feeCreatedAt;
  final DateTime feeUpdatedAt;
  final int adminId;
  final double feeAmount;

  FeeModel({
    this.feeId,
    required this.feeDescription,
    required this.feeDue,
    required this.feeType,
    required this.feeCreatedAt,
    required this.feeUpdatedAt,
    required this.adminId,
    required this.feeAmount,
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
      feeAmount: (json['fee_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'fee_description': feeDescription,
      'fee_due': feeDue.toIso8601String(),
      'fee_type': feeType,
      'fee_created_at': feeCreatedAt.toIso8601String(),
      'fee_updated_at': feeUpdatedAt.toIso8601String(),
      'admin_id': adminId,
      'fee_amount': feeAmount,
    };

    if (feeId != null) {
      data['fee_id'] = feeId as int; // Cast to non-nullable int
    }

    return data;
  }

  FeeModel copyWith({
    int? feeId,
    String? feeDescription,
    DateTime? feeDue,
    String? feeType,
    DateTime? feeCreatedAt,
    DateTime? feeUpdatedAt,
    int? adminId,
    double? feeAmount,
    String? feeStatus,
  }) {
    return FeeModel(
      feeId: feeId ?? this.feeId,
      feeDescription: feeDescription ?? this.feeDescription,
      feeDue: feeDue ?? this.feeDue,
      feeType: feeType ?? this.feeType,
      feeCreatedAt: feeCreatedAt ?? this.feeCreatedAt,
      feeUpdatedAt: feeUpdatedAt ?? this.feeUpdatedAt,
      adminId: adminId ?? this.adminId,
      feeAmount: feeAmount ?? this.feeAmount,
    );
  }

  @override
  String toString() {
    return 'FeeModel(feeId: $feeId, description: $feeDescription, due: $feeDue, type: $feeType, amount: $feeAmount)';
  }
}
