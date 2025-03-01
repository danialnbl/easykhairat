class User {
  final int? userId;
  final String userName;
  final String userIdentification;
  final String userPhoneNo;
  final String userAddress;
  final String userEmail;
  final String userType;
  final String userPassword;
  final DateTime? userCreatedAt;
  final DateTime? userUpdatedAt;

  User({
    this.userId,
    required this.userName,
    required this.userIdentification,
    required this.userPhoneNo,
    required this.userAddress,
    required this.userEmail,
    required this.userType,
    required this.userPassword,
    this.userCreatedAt,
    this.userUpdatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String,
      userIdentification: json['user_identification'] as String,
      userPhoneNo: json['user_phoneNo'] as String,
      userAddress: json['user_address'] as String,
      userEmail: json['user_email'] as String,
      userType: json['user_type'] as String,
      userPassword: json['user_password'] as String,
      userCreatedAt:
          json['user_created_at'] != null
              ? DateTime.parse(json['user_created_at'])
              : null,
      userUpdatedAt:
          json['user_updated_at'] != null
              ? DateTime.parse(json['user_updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_identification': userIdentification,
      'user_phoneNo': userPhoneNo,
      'user_address': userAddress,
      'user_email': userEmail,
      'user_type': userType,
      'user_password': userPassword,
      'user_created_at': userCreatedAt?.toIso8601String(),
      'user_updated_at': userUpdatedAt?.toIso8601String(),
    };
  }

  /// Useful when inserting into Supabase (skips auto fields like created_at and user_id)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_name': userName,
      'user_identification': userIdentification,
      'user_phoneNo': userPhoneNo,
      'user_address': userAddress,
      'user_email': userEmail,
      'user_type': userType,
      'user_password': userPassword,
      // Don't include `created_at` or `user_id` here because Supabase can handle them
    };
  }
}
