class PaymentModel {
  final int paymentId;
  final double paymentValue;
  final String paymentDescription;
  final DateTime paymentCreatedAt;
  final DateTime paymentUpdatedAt;
  final int feeId;
  final String? userId;
  final String? paymentType; // Added nullable paymentType

  PaymentModel({
    required this.paymentId,
    required this.paymentValue,
    required this.paymentDescription,
    required this.paymentCreatedAt,
    required this.paymentUpdatedAt,
    required this.feeId,
    this.userId,
    this.paymentType, // Added to constructor
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id'],
      paymentValue: (json['payment_value'] as num).toDouble(),
      paymentDescription: json['payment_description'],
      paymentCreatedAt: DateTime.parse(json['payment_created_at']),
      paymentUpdatedAt: DateTime.parse(json['payment_updated_at']),
      feeId: json['fee_id'],
      userId: json['user_id'],
      paymentType: json['payment_type'], // Added to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'payment_value': paymentValue,
      'payment_description': paymentDescription,
      'payment_created_at': paymentCreatedAt.toIso8601String(),
      'payment_updated_at': paymentUpdatedAt.toIso8601String(),
      'fee_id': feeId,
      'user_id': userId,
      'payment_type': paymentType, // Added to toJson
    };
  }

  @override
  String toString() {
    return 'PaymentModel(paymentId: $paymentId, value: $paymentValue, description: $paymentDescription, userId: $userId, feeId: $feeId, paymentType: $paymentType)'; // Updated toString
  }
}
