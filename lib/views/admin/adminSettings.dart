import 'package:easykhairat/views/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({Key? key}) : super(key: key);

  @override
  _AdminSettingsState createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final surfaceColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: Colors.black26,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(surfaceColor!, textColor),
                    _buildSectionTitle('Account', textColor),
                    _buildSettingItem(
                      MoonIcons.generic_user_32_regular,
                      'My Profile',
                      surfaceColor,
                      textColor,
                      onTap: () {
                        // Get.to(() => ProfilePageWidget());
                      },
                    ),
                    _buildSectionTitle('General', textColor),
                    _buildSettingItem(
                      Icons.account_circle_outlined,
                      'Edit Profile',
                      surfaceColor,
                      textColor,
                    ),
                    _buildSettingItem(
                      MoonIcons.generic_log_out_16_light,
                      'Log Out',
                      surfaceColor,
                      textColor,
                      onTap: () {
                        userController.signOut().then((value) {
                          Get.offAll(() => SignInWidget());
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color surfaceColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String label,
    Color surfaceColor,
    Color textColor, {
    double bottomPadding = 12,
    VoidCallback? onTap, // Optional tap handler
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300), // Light border
          boxShadow: const [
            BoxShadow(
              color: Colors.black26, // Shadow color
              blurRadius: 5,
              offset: Offset(0, 2), // Slight vertical offset
            ),
          ],
        ),
        child: MoonMenuItem(
          backgroundColor: surfaceColor, // Keep same background color
          leading: Icon(icon, color: textColor),
          label: Text(label, style: TextStyle(fontSize: 16, color: textColor)),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: textColor.withOpacity(0.6),
          ),
          height: 60,
          borderRadius: BorderRadius.circular(12), // Same border radius
          onTap: onTap,
        ),
      ),
    );
  }
}
