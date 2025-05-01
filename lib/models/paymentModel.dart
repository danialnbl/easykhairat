class PaymentModel {
  final int paymentId;
  final double paymentValue;
  final String paymentDescription;
  final DateTime paymentCreatedAt;
  final DateTime paymentUpdatedAt;
  final String userId;
  final int feeId;

  PaymentModel({
    required this.paymentId,
    required this.paymentValue,
    required this.paymentDescription,
    required this.paymentCreatedAt,
    required this.paymentUpdatedAt,
    required this.userId,
    required this.feeId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id'],
      paymentValue: (json['payment_value'] as num).toDouble(),
      paymentDescription: json['payment_description'],
      paymentCreatedAt: DateTime.parse(json['payment_created_at']),
      paymentUpdatedAt: DateTime.parse(json['payment_updated_at']),
      userId: json['user_id'],
      feeId: json['fee_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'payment_value': paymentValue,
      'payment_description': paymentDescription,
      'payment_created_at': paymentCreatedAt.toIso8601String(),
      'payment_updated_at': paymentUpdatedAt.toIso8601String(),
      'user_id': userId,
      'fee_id': feeId,
    };
  }

  @override
  String toString() {
    return 'PaymentModel(paymentId: $paymentId, value: $paymentValue, description: $paymentDescription, feeId: $feeId, userId: $userId)';
  }
}
