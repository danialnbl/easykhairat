import 'package:easykhairat/views/auth/signIn.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/models/userModel.dart';
import 'package:moon_design/moon_design.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final UserController userController = Get.find<UserController>();
  User? currentUser;
  bool isLoading = true;
  bool isEditing = false;

  // Add these controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController icController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    icController.dispose();
    super.dispose();
  }

  Future<void> fetchCurrentUser() async {
    final userId = userController.supabase.auth.currentUser?.id;
    if (userId != null) {
      final user = await userController.fetchUserById(userId);
      setState(() {
        currentUser = user;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: "Admin Profile",
                notificationCount: 3,
                onNotificationPressed: () {},
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: MoonColors.light.goku,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MoonBreadcrumb(
                      items: [
                        MoonBreadcrumbItem(
                          label: Text(
                            "Home",
                            style: const TextStyle(color: Colors.black),
                          ),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(
                          label: Text(
                            "Profile",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : currentUser == null
                  ? const Center(child: Text("No user data available"))
                  : Form(
                    key: formKey,
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Maklumat Admin",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _toggleEditing,
                                  icon: Icon(
                                    isEditing ? Icons.close : Icons.edit,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isEditing ? "Batal" : "Kemaskini",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isEditing ? Colors.red : Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller:
                                  nameController
                                    ..text = currentUser?.userName ?? "",
                              decoration: const InputDecoration(
                                labelText: 'Nama',
                                border: OutlineInputBorder(),
                              ),
                              enabled: isEditing,
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Sila masukkan nama'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller:
                                  emailController
                                    ..text = currentUser?.userEmail ?? "",
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              enabled: isEditing,
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Sila masukkan email';
                                if (!GetUtils.isEmail(value!))
                                  return 'Sila masukkan email yang sah';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller:
                                  icController
                                    ..text =
                                        currentUser?.userIdentification ?? "",
                              decoration: const InputDecoration(
                                labelText: 'No. Kad Pengenalan',
                                border: OutlineInputBorder(),
                              ),
                              enabled: isEditing,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller:
                                  phoneController
                                    ..text = currentUser?.userPhoneNo ?? "",
                              decoration: const InputDecoration(
                                labelText: 'No. Telefon',
                                border: OutlineInputBorder(),
                              ),
                              enabled: isEditing,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller:
                                  addressController
                                    ..text = currentUser?.userAddress ?? "",
                              decoration: const InputDecoration(
                                labelText: 'Alamat',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              enabled: isEditing,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: currentUser?.userType ?? "",
                              decoration: const InputDecoration(
                                labelText: 'Status Keahlian',
                                border: OutlineInputBorder(),
                              ),
                              enabled:
                                  false, // Keep this disabled as type shouldn't be editable
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue:
                                  currentUser?.userCreatedAt
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                              decoration: const InputDecoration(
                                labelText: 'Tarikh Dicipta',
                                border: OutlineInputBorder(),
                              ),
                              enabled:
                                  false, // Keep this disabled as creation date shouldn't be editable
                            ),
                            if (isEditing) ...[
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text('Simpan'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: TextStyle(color: textColor)),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor),
      title: Text(label, style: TextStyle(color: textColor)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: textColor.withOpacity(0.6),
      ),
    );
  }

  void _showEditProfileBottomSheet() {
    final nameController = TextEditingController(text: currentUser?.userName);
    final emailController = TextEditingController(text: currentUser?.userEmail);
    final phoneController = TextEditingController(
      text: currentUser?.userPhoneNo,
    );
    final addressController = TextEditingController(
      text: currentUser?.userAddress,
    );
    final icController = TextEditingController(
      text: currentUser?.userIdentification,
    );

    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter your name'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter your email';
                    if (!GetUtils.isEmail(value!))
                      return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter your phone number'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter your address'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: icController,
                  decoration: const InputDecoration(
                    labelText: 'IC Number',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter your IC number'
                              : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      try {
                        final updatedUser = currentUser?.copyWith(
                          userName: nameController.text,
                          userEmail: emailController.text,
                          userPhoneNo: phoneController.text,
                          userAddress: addressController.text,
                          userIdentification: icController.text,
                          userUpdatedAt: DateTime.now(),
                        );

                        if (updatedUser != null) {
                          await userController.updateUser(updatedUser);
                          Get.back();
                          fetchCurrentUser(); // Refresh the profile data
                          Get.snackbar(
                            'Success',
                            'Profile updated successfully',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to update profile',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _toggleEditing() {
    if (isEditing) {
      Get.dialog(
        AlertDialog(
          title: Text('Batal Kemaskini?'),
          content: Text('Perubahan yang belum disimpan akan hilang. Teruskan?'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Batal')),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.pop(context);
                setState(() {
                  isEditing = false;
                  // Reset controllers to original values
                  nameController.text = currentUser?.userName ?? "";
                  emailController.text = currentUser?.userEmail ?? "";
                  phoneController.text = currentUser?.userPhoneNo ?? "";
                  addressController.text = currentUser?.userAddress ?? "";
                  icController.text = currentUser?.userIdentification ?? "";
                });
              },
              child: Text('Ya'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final updatedUser = currentUser?.copyWith(
          userName: nameController.text,
          userEmail: emailController.text,
          userPhoneNo: phoneController.text,
          userAddress: addressController.text,
          userIdentification: icController.text,
          userUpdatedAt: DateTime.now(),
        );

        if (updatedUser != null) {
          await userController.updateUser(updatedUser);
          setState(() {
            isEditing = false;
            currentUser = updatedUser;
          });
          Get.snackbar(
            'Berjaya',
            'Profil telah dikemaskini',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Ralat',
          'Gagal mengemaskini profil',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
