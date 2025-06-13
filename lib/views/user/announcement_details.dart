import 'package:easykhairat/models/announcementModel.dart';
import 'package:easykhairat/views/user/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:share_plus/share_plus.dart';

class AnnouncementDetailsPage extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailsPage({Key? key, required this.announcement})
    : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy • hh:mm a').format(date);
  }

  void _shareAnnouncement() {
    final String title = announcement.announcementTitle;
    final String desc = announcement.announcementDescription;
    final String type = announcement.announcementType;
    final String date = _formatDate(announcement.announcementCreatedAt);

    Share.share(
      '[$type] $title\n\n$desc\n\nDiterbitkan pada $date melalui Aplikasi EasyKhairat',
      subject: 'Pengumuman dari EasyKhairat: $title',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeath =
        announcement.announcementType.toLowerCase() == 'Kematian';
    final Color primaryColor =
        isDeath ? Colors.red.shade800 : MoonColors.light.bulma;
    final Color secondaryColor =
        isDeath ? Colors.red.shade100 : MoonColors.light.bulma.withOpacity(0.2);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar:
          announcement.announcementImage != null &&
          announcement.announcementImage!.isNotEmpty,
      appBar: AppBar(
        backgroundColor:
            announcement.announcementImage != null &&
                    announcement.announcementImage!.isNotEmpty
                ? Colors.transparent
                : Colors.white,
        elevation:
            announcement.announcementImage != null &&
                    announcement.announcementImage!.isNotEmpty
                ? 0
                : 1,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Get.to(HomePageWidget()),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.share, color: primaryColor),
              onPressed: _shareAnnouncement,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with gradient overlay
            if (announcement.announcementImage != null &&
                announcement.announcementImage!.isNotEmpty)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
                    child: Image.network(
                      announcement.announcementImage!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            color: primaryColor,
                          ),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Imej tidak tersedia',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ),

                  // Add gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Type badge over image
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDeath ? Colors.red : MoonColors.light.bulma,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDeath
                            ? 'KEMATIAN'
                            : announcement.announcementType.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            Card(
              margin: EdgeInsets.all(16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show type badge if no image
                    if (announcement.announcementImage == null ||
                        announcement.announcementImage!.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          announcement.announcementType.toUpperCase(),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    if (announcement.announcementImage == null ||
                        announcement.announcementImage!.isEmpty)
                      SizedBox(height: 16),

                    // Title
                    Text(
                      announcement.announcementTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: primaryColor,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Date with better formatting
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            _formatDate(announcement.announcementCreatedAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Divider
                    Divider(thickness: 1, color: Colors.grey[200]),

                    SizedBox(height: 16),

                    // Description with better styling
                    Text(
                      announcement.announcementDescription,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Additional info card for death announcements
                    if (isDeath)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.red.shade800,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Maklumat Penting',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sila sertai kami untuk solat jenazah. Kehadiran dan '
                              'doa anda akan menjadi penghibur kepada keluarga si mati.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade900,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: MoonButton(
                onTap: () => Get.to(HomePageWidget()),
                backgroundColor: Colors.grey.shade100,
                textColor: Colors.black87,
                label: Text("Kembali"),
                borderRadius: BorderRadius.circular(50),
                buttonSize: MoonButtonSize.lg,
                showBorder: true,
                showScaleEffect: true,
                height: 50,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MoonButton(
                onTap: _shareAnnouncement,
                backgroundColor: primaryColor,
                textColor: Colors.white,
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, size: 18),
                    SizedBox(width: 8),
                    Text("Kongsi"),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
                buttonSize: MoonButtonSize.lg,
                showBorder: false,
                showScaleEffect: true,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
