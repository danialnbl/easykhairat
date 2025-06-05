import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:easykhairat/views/user/familyProfile.dart';
import 'package:easykhairat/views/user/profile.dart';
import 'package:flutter/material.dart';
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/easyKhairatLogo.png',
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
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
                            Icons.person,
                            'Profil Saya',
                            surfaceColor,
                            textColor,
                            accentColor,
                            onTap: () {
                              Get.to(() => ProfilePageWidget());
                            },
                          ),
                          _buildSettingItem(
                            Icons.people,
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
                            Icons.help_outline,
                            'Bantuan & Sokongan',
                            surfaceColor,
                            textColor,
                            accentColor,
                            onTap: () {
                              _showSupportDialog(
                                context,
                                textColor,
                                backgroundColor!,
                                accentColor,
                              );
                            },
                          ),
                          _buildSettingItem(
                            Icons.info_outline,
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
                            Icons.logout,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color surfaceColor, Color textColor, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tetapan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sesuaikan pengalaman aplikasi anda',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 20,
            child: Icon(Icons.settings, size: 28, color: Colors.white),
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
              fontSize: 16,
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
      child: Card(
        elevation: 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSupportDialog(
    BuildContext context,
    Color textColor,
    Color backgroundColor,
    Color accentColor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: backgroundColor,
          title: Row(
            children: [
              Icon(Icons.support_agent, color: accentColor),
              const SizedBox(width: 10),
              Text('Contact Support', style: TextStyle(color: textColor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.1),
                  child: Icon(Icons.phone, color: accentColor),
                ),
                title: Text('Call Admin', style: TextStyle(color: textColor)),
                subtitle: Text(
                  '012-345-6789',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
                onTap: () {
                  // Implement call functionality
                  Get.back();
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.1),
                  child: Icon(Icons.email, color: accentColor),
                ),
                title: Text('Email', style: TextStyle(color: textColor)),
                subtitle: Text(
                  'support@easykhairat.com',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
                onTap: () {
                  // Implement email functionality
                  Get.back();
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Tentang EasyKhairat',
            style: TextStyle(color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Versi: 1.0.0', style: TextStyle(color: textColor)),
              const SizedBox(height: 8),
              Text(
                'Aplikasi pengurusan khairat kematian mudah untuk komuniti.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 12),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Log Keluar', style: TextStyle(color: textColor)),
          content: Text(
            'Adakah anda pasti ingin log keluar?',
            style: TextStyle(color: textColor),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: textColor.withOpacity(0.7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                userController.signOut().then((value) {
                  Get.offAll(() => SignInPage());
                });
              },
              child: const Text('Log Keluar'),
            ),
          ],
        );
      },
    );
  }
}
