import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  bool isDarkMode = false;

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDarkMode ? Colors.grey[900] : MoonColors.light.gohan;
    final surfaceColor = isDarkMode ? Colors.grey[800] : MoonColors.light.gohan;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final userController = Get.find<UserController>();

    // Get the current user ID
    final uuid = Supabase.instance.client.auth.currentUser?.id;

    if (uuid == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                MoonIcons
                    .notifications_error_24_regular, // Using a more suitable MoonDesign error icon
                size: 48,
                color: Colors.black, // Redish color from MoonColors
              ),
              const SizedBox(height: 16),
              const Text(
                "Something wrong here...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We’re having technical issues (as you can see)\nPlease try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 16),
              MoonFilledButton(
                label: const Text("Back to login"),
                onTap: () {
                  Get.to(
                    () => const SignInPage(),
                  ); // Make sure SignInWidget exists
                },
              ),
            ],
          ),
        ),
      );
    }

    // Use StreamBuilder to listen for changes to the user's profile
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: userController.streamProfileByUserID(uuid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('User profile not found'));
        }

        final profileData = snapshot.data!.first;

        // Update the text controllers when data is fetched
        nameController.text = profileData['user_name'] ?? '';
        emailController.text = profileData['user_email'] ?? '';
        phoneController.text = profileData['user_phone_no'] ?? '';
        addressController.text = profileData['user_address'] ?? '';

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [_buildProfileCard(surfaceColor!, textColor)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(Color surfaceColor, Color textColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Colors.black26,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(surfaceColor, textColor),
          _buildSectionTitle('Name', textColor),
          _buildSettingItem(nameController),
          _buildSectionTitle('Email', textColor),
          _buildSettingItem(emailController),
          _buildSectionTitle('Phone Number', textColor),
          _buildSettingItem(phoneController),
          _buildSectionTitle('Address', textColor),
          _buildTextArea(addressController),
          _buildSectionTitle('New Password', textColor),
          _buildSettingItem(passwordController, obscureText: true),
          _buildSectionTitle('Confirm New Password', textColor),
          _buildSettingItem(confirmController, obscureText: true),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: MoonFilledButton(
                buttonSize: MoonButtonSize.sm,
                onTap: () {
                  // Add your update logic here
                  print('Update profile');
                },
                leading: const Icon(MoonIcons.generic_edit_16_light),
                label: const Text("Edit"),
              ),
            ),
          ),
        ],
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
      child: const Text(
        'Profile',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      child: Text(title, style: TextStyle(fontSize: 18, color: textColor)),
    );
  }

  Widget _buildSettingItem(
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: MoonTextInput(
        controller: controller,
        textInputSize: MoonTextInputSize.md,
        obscureText: obscureText,
        backgroundColor: Colors.transparent,
        cursorColor: MoonColors.light.trunks,
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: MoonTextArea(
        controller: controller,
        height: 100,
        validator:
            (String? value) =>
                (value?.length ?? 0) < 5
                    ? "Address should be longer than 5 characters."
                    : null,
      ),
    );
  }
}
