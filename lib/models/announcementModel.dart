class AnnouncementModel {
  final int? announcementId;
  final String announcementTitle;
  final String announcementDescription;
  final String announcementType;
  final DateTime announcementCreatedAt;
  final DateTime? announcementUpdatedAt;
  final int adminId;
  final String? announcementImage;

  AnnouncementModel({
    this.announcementId,
    required this.announcementTitle,
    required this.announcementDescription,
    required this.announcementType,
    required this.announcementCreatedAt,
    this.announcementUpdatedAt,
    required this.adminId,
    this.announcementImage,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      announcementId: json['announcement_id'],
      announcementTitle: json['announcement_title'],
      announcementDescription: json['announcement_description'],
      announcementType: json['announcement_type'],
      announcementCreatedAt: DateTime.parse(json['announcement_created_at']),
      announcementUpdatedAt:
          json['announcement_updated_at'] != null
              ? DateTime.parse(json['announcement_updated_at'])
              : null,
      adminId: json['admin_id'],
      announcementImage: json['announcement_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (announcementId != null) 'announcement_id': announcementId,
      'announcement_title': announcementTitle,
      'announcement_description': announcementDescription,
      'announcement_type': announcementType,
      'announcement_created_at': announcementCreatedAt.toIso8601String(),
      'announcement_updated_at': announcementUpdatedAt?.toIso8601String(),
      'admin_id': adminId,
      'announcement_image': announcementImage,
    };
  }

  AnnouncementModel copyWith({
    int? announcementId,
    String? announcementTitle,
    String? announcementDescription,
    String? announcementType,
    DateTime? announcementCreatedAt,
    DateTime? announcementUpdatedAt,
    int? adminId,
    String? announcementImage,
  }) {
    return AnnouncementModel(
      announcementId: announcementId ?? this.announcementId,
      announcementTitle: announcementTitle ?? this.announcementTitle,
      announcementDescription:
          announcementDescription ?? this.announcementDescription,
      announcementType: announcementType ?? this.announcementType,
      announcementCreatedAt:
          announcementCreatedAt ?? this.announcementCreatedAt,
      announcementUpdatedAt:
          announcementUpdatedAt ?? this.announcementUpdatedAt,
      adminId: adminId ?? this.adminId,
      announcementImage: announcementImage ?? this.announcementImage,
    );
  }

  @override
  String toString() {
    return 'AnnouncementModel(id: $announcementId, title: $announcementTitle, type: $announcementType)';
  }
}
