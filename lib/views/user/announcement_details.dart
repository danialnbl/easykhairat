import 'package:easykhairat/models/announcementModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';

class AnnouncementDetailsPage extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailsPage({Key? key, required this.announcement})
    : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeath = announcement.announcementType.toLowerCase() == 'death';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isDeath ? 'Death Announcement' : 'Announcement',
          style: TextStyle(
            color: isDeath ? Colors.black : MoonColors.light.bulma,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MoonColors.light.bulma),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image if available
            if (announcement.announcementImage != null &&
                announcement.announcementImage!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: Image.network(
                  announcement.announcementImage!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Center(
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
                              'Image not available',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isDeath
                              ? Colors.red.shade100
                              : MoonColors.light.bulma.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      announcement.announcementType,
                      style: TextStyle(
                        color:
                            isDeath
                                ? Colors.red.shade800
                                : MoonColors.light.bulma,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Title
                  Text(
                    announcement.announcementTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: isDeath ? Colors.black : MoonColors.light.bulma,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Posted: ${_formatDate(announcement.announcementCreatedAt)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Divider
                  Divider(thickness: 1, color: Colors.grey[300]),

                  SizedBox(height: 16),

                  // Description
                  Text(
                    announcement.announcementDescription,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 30),
                ],
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
        child: MoonButton(
          onTap: () => Get.back(),
          backgroundColor:
              isDeath
                  ? Colors.red.shade100
                  : MoonColors.light.bulma.withOpacity(0.2),
          textColor: isDeath ? Colors.red.shade800 : MoonColors.light.bulma,
          label: Text("Back to Home"),
          borderRadius: BorderRadius.circular(50),
          buttonSize: MoonButtonSize.lg,
          showBorder: false,
          showScaleEffect: true,
          height: 50,
        ),
      ),
    );
  }
}
