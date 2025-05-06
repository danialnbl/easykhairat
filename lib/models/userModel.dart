class User {
  final String userName;
  final String userIdentification;
  final String userPhoneNo;
  final String userAddress;
  final String userEmail;
  final String userType;
  final String userPassword;
  final DateTime userCreatedAt;
  final DateTime? userUpdatedAt;
  final String? userId;

  User({
    required this.userName,
    required this.userIdentification,
    required this.userPhoneNo,
    required this.userAddress,
    required this.userEmail,
    required this.userType,
    required this.userPassword,
    required this.userCreatedAt,
    this.userUpdatedAt,
    this.userId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['user_name'],
      userIdentification: json['user_identification'],
      userPhoneNo: json['user_phone_no'],
      userAddress: json['user_address'],
      userEmail: json['user_email'],
      userType: json['user_type'],
      userPassword: json['user_password'],
      userCreatedAt: DateTime.parse(json['user_created_at']),
      userUpdatedAt: DateTime.parse(json['user_updated_at']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'user_identification': userIdentification,
      'user_phone_no': userPhoneNo,
      'user_address': userAddress,
      'user_email': userEmail,
      'user_type': userType,
      'user_password': userPassword,
      'user_created_at': userCreatedAt.toIso8601String(),
      'user_updated_at': userUpdatedAt?.toIso8601String(), // Ensure null safety
      'user_id': userId,
    };
  }

  User copyWith({
    String? userName,
    String? userIdentification,
    String? userPhoneNo,
    String? userAddress,
    String? userEmail,
    String? userType,
    String? userPassword,
    DateTime? userCreatedAt,
    DateTime? userUpdatedAt,
    String? userId,
  }) {
    return User(
      userName: userName ?? this.userName,
      userIdentification: userIdentification ?? this.userIdentification,
      userPhoneNo: userPhoneNo ?? this.userPhoneNo,
      userAddress: userAddress ?? this.userAddress,
      userEmail: userEmail ?? this.userEmail,
      userType: userType ?? this.userType,
      userPassword: userPassword ?? this.userPassword,
      userCreatedAt: userCreatedAt ?? this.userCreatedAt,
      userUpdatedAt: userUpdatedAt ?? this.userUpdatedAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'User(userName: $userName, email: $userEmail, phone: $userPhoneNo)';
  }
}
