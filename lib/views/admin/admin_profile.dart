import 'package:easykhairat/views/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/models/userModel.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final UserController userController = Get.find<UserController>();
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
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
    final backgroundColor = Colors.grey[100];
    final surfaceColor = Colors.white;
    final textColor = Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text('Admin Profile', style: TextStyle(color: textColor)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : currentUser == null
              ? const Center(child: Text("No user data available"))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Details Card
                      Card(
                        color: surfaceColor,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Maklumat Admin",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                "Nama :",
                                currentUser?.userName ?? "N/A",
                                textColor,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                "Email :",
                                currentUser?.userEmail ?? "N/A",
                                textColor,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                "No. Kad Pengenalan :",
                                currentUser?.userIdentification ?? "N/A",
                                textColor,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                "No. Telefon :",
                                currentUser?.userPhoneNo ?? "N/A",
                                textColor,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                "Alamat :",
                                currentUser?.userAddress ?? "N/A",
                                textColor,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                "Status Keahlian :",
                                currentUser?.userType ?? "N/A",
                                textColor,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                "Tarikh Dicipta :",
                                currentUser?.userCreatedAt
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0] ??
                                    "N/A",
                                textColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Profile Options
                      Card(
                        color: surfaceColor,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildProfileOption(
                                icon: Icons.edit_outlined,
                                label: 'Edit Profile',
                                textColor: textColor,
                                onTap: () {
                                  // Navigate to Edit Profile page
                                },
                              ),
                              _buildProfileOption(
                                icon: Icons.logout,
                                label: 'Log Out',
                                textColor: textColor,
                                onTap: () {
                                  userController.signOut().then((value) {
                                    Get.offAll(() => SignInPage());
                                  });
                                },
                              ),
                            ],
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
}
