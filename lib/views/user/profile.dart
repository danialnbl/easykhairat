import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:flutter/material.dart';
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

  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final surfaceColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = isDarkMode ? Colors.tealAccent : Colors.teal;

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
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                "We're having technical issues (as you can see)\nPlease try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => const SignInPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Back to login"),
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
          return Scaffold(
            backgroundColor: backgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: const Center(child: Text('User profile not found')),
          );
        }

        final profileData = snapshot.data!.first;

        // Update the text controllers when data is fetched
        nameController.text = profileData['user_name'] ?? '';
        emailController.text = profileData['user_email'] ?? '';
        phoneController.text = profileData['user_phone_no'] ?? '';
        addressController.text = profileData['user_address'] ?? '';

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: accentColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Profil Saya',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileCard(
                    surfaceColor!,
                    textColor,
                    accentColor,
                    profileData,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(
    Color surfaceColor,
    Color textColor,
    Color accentColor,
    Map<String, dynamic> profileData,
  ) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(surfaceColor, textColor, accentColor),
          _buildSectionTitle('Nama', textColor, accentColor),
          _buildSettingItem(
            nameController,
            isEnabled: _isEditing,
            textColor: textColor,
            accentColor: accentColor,
          ),
          _buildSectionTitle('Email', textColor, accentColor),
          _buildSettingItem(
            emailController,
            isEnabled: _isEditing,
            textColor: textColor,
            accentColor: accentColor,
          ),
          _buildSectionTitle('Nombor Telefon', textColor, accentColor),
          _buildSettingItem(
            phoneController,
            isEnabled: _isEditing,
            textColor: textColor,
            accentColor: accentColor,
          ),
          _buildSectionTitle('Alamat', textColor, accentColor),
          _buildTextArea(
            addressController,
            isEnabled: _isEditing,
            textColor: textColor,
            accentColor: accentColor,
          ),
          if (_isEditing) ...[
            _buildSectionTitle('Katalaluan Baru', textColor, accentColor),
            _buildSettingItem(
              passwordController,
              obscureText: true,
              isEnabled: true,
              textColor: textColor,
              accentColor: accentColor,
            ),
            _buildSectionTitle(
              'Sahkan Katalaluan Baru',
              textColor,
              accentColor,
            ),
            _buildSettingItem(
              confirmController,
              obscureText: true,
              isEnabled: true,
              textColor: textColor,
              accentColor: accentColor,
            ),
          ],
          _buildActionButtons(
            surfaceColor,
            textColor,
            accentColor,
            profileData,
          ),
        ],
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
                  'Profil Saya',
                  style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kemaskini maklumat peribadi anda',
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
            child: Icon(Icons.person, size: 28, color: Colors.white),
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
    TextEditingController controller, {
    bool obscureText = false,
    bool isEnabled = false,
    required Color textColor,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: !isEnabled,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: isEnabled ? Colors.grey.shade100 : Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isEnabled ? accentColor : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentColor, width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        cursorColor: accentColor,
      ),
    );
  }

  Widget _buildTextArea(
    TextEditingController controller, {
    bool isEnabled = false,
    required Color textColor,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: !isEnabled,
        maxLines: 4,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: isEnabled ? Colors.grey.shade100 : Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isEnabled ? accentColor : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentColor, width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        cursorColor: accentColor,
        validator:
            (String? value) =>
                (value?.length ?? 0) < 5
                    ? "Alamat perlu melebihi 5 aksara."
                    : null,
      ),
    );
  }

  Widget _buildActionButtons(
    Color surfaceColor,
    Color textColor,
    Color accentColor,
    Map<String, dynamic> profileData,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isEditing) ...[
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset controllers to original values
                  nameController.text = profileData['user_name'] ?? '';
                  emailController.text = profileData['user_email'] ?? '';
                  phoneController.text = profileData['user_phone_no'] ?? '';
                  addressController.text = profileData['user_address'] ?? '';
                  passwordController.clear();
                  confirmController.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: textColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Batal', style: TextStyle(color: textColor)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveProfile(profileData['user_id']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              icon: const Icon(Icons.save, size: 18),
              label: const Text("Simpan"),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text("Kemaskini"),
            ),
          ],
        ],
      ),
    );
  }

  void _saveProfile(String userId) async {
    // Check if password and confirm password match
    if (passwordController.text.isNotEmpty &&
        passwordController.text != confirmController.text) {
      Get.snackbar(
        'Error',
        'Katalaluan tidak sepadan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final userController = Get.find<UserController>();

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Create updated user object
      final updatedUser = {
        'user_id': userId,
        'user_name': nameController.text,
        'user_email': emailController.text,
        'user_phone_no': phoneController.text,
        'user_address': addressController.text,
        'user_updated_at': DateTime.now().toIso8601String(),
      };

      // Add password if it was changed
      if (passwordController.text.isNotEmpty) {
        updatedUser['user_password'] = passwordController.text;
      }

      // Update user profile
      await userController.supabase
          .from('users')
          .update(updatedUser)
          .eq('user_id', userId);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      Get.snackbar(
        'Berjaya',
        'Profil telah dikemaskini',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      setState(() {
        _isEditing = false;
        passwordController.clear();
        confirmController.clear();
      });
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      Get.snackbar(
        'Ralat',
        'Gagal mengemaskini profil: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
