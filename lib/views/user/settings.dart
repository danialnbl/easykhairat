import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:easykhairat/views/user/familyProfile.dart';
import 'package:easykhairat/views/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isDarkMode = false;
  final userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  // Load dark mode preference
  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save dark mode preference
  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final surfaceColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = isDarkMode ? Colors.tealAccent : Colors.teal;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                      _buildHeader(surfaceColor!, textColor, accentColor),
                      _buildSectionTitle('Akaun', textColor, accentColor),
                      _buildSettingItem(
                        MoonIcons.generic_user_32_regular,
                        'Profil Saya',
                        surfaceColor,
                        textColor,
                        accentColor,
                        onTap: () {
                          Get.to(() => ProfilePageWidget());
                        },
                      ),
                      _buildSettingItem(
                        MoonIcons.generic_users_32_regular,
                        'Profil Keluarga',
                        surfaceColor,
                        textColor,
                        accentColor,
                        onTap: () {
                          Get.to(() => FamilyProfile());
                        },
                      ),
                      _buildSectionTitle('Umum', textColor, accentColor),
                      _buildSettingItem(
                        MoonIcons.generic_help_32_regular,
                        'Bantuan & Sokongan',
                        surfaceColor,
                        textColor,
                        accentColor,
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.support_agent,
                                    color: MoonColors.light.bulma,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Contact Support'),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: MoonColors.light.bulma
                                          .withOpacity(0.1),
                                      child: Icon(
                                        Icons.phone,
                                        color: MoonColors.light.bulma,
                                      ),
                                    ),
                                    title: Text('Call Admin'),
                                    subtitle: Text('012-345-6789'),
                                    onTap: () {
                                      // Implement call functionality
                                      Get.back();
                                    },
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: MoonColors.light.bulma
                                          .withOpacity(0.1),
                                      child: Icon(
                                        Icons.email,
                                        color: MoonColors.light.bulma,
                                      ),
                                    ),
                                    title: Text('Email'),
                                    subtitle: Text('support@easykhairat.com'),
                                    onTap: () {
                                      // Implement email functionality
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                MoonButton(
                                  onTap: () => Get.back(),
                                  backgroundColor: Colors.grey[200],
                                  textColor: Colors.black87,
                                  label: Text("Close"),
                                  borderRadius: BorderRadius.circular(50),
                                  buttonSize: MoonButtonSize.md,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        MoonIcons.generic_info_16_light,
                        'Tentang Aplikasi',
                        surfaceColor,
                        textColor,
                        accentColor,
                        onTap: () {
                          _showAboutDialog(
                            context,
                            textColor,
                            backgroundColor!,
                            accentColor,
                          );
                        },
                      ),
                      _buildSettingItem(
                        MoonIcons.generic_log_out_16_light,
                        'Log Keluar',
                        surfaceColor,
                        textColor,
                        accentColor,
                        bottomPadding: 16,
                        onTap: () {
                          _showLogoutConfirmDialog(
                            context,
                            textColor,
                            backgroundColor!,
                            accentColor,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color surfaceColor, Color textColor, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
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
                  'Tetapan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sesuaikan pengalaman aplikasi anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            MoonIcons.generic_settings_32_regular,
            size: 28,
            color: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String label,
    Color surfaceColor,
    Color textColor,
    Color accentColor, {
    double bottomPadding = 12,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: MoonMenuItem(
          backgroundColor: surfaceColor,
          leading: Icon(icon, color: accentColor),
          label: Text(label, style: TextStyle(fontSize: 16, color: textColor)),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: textColor.withOpacity(0.6),
          ),
          height: 60,
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showAboutDialog(
    BuildContext context,
    Color textColor,
    Color backgroundColor,
    Color accentColor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Tentang EasyKhairat',
            style: TextStyle(color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Versi: 1.0.0', style: TextStyle(color: textColor)),
              SizedBox(height: 8),
              Text(
                'Aplikasi pengurusan khairat kematian mudah untuk komuniti.',
                style: TextStyle(color: textColor),
              ),
              SizedBox(height: 12),
              Text(
                '© 2024 EasyKhairat',
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup', style: TextStyle(color: accentColor)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmDialog(
    BuildContext context,
    Color textColor,
    Color backgroundColor,
    Color accentColor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('Log Keluar', style: TextStyle(color: textColor)),
          content: Text(
            'Adakah anda pasti ingin log keluar?',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              onPressed: () {
                Navigator.of(context).pop();
                userController.signOut().then((value) {
                  Get.offAll(() => SignInPage());
                });
              },
              child: Text('Log Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
