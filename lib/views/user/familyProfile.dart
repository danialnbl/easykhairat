import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/controllers/family_controller.dart';
import 'package:easykhairat/models/familyModel.dart';

class FamilyProfile extends StatefulWidget {
  const FamilyProfile({Key? key}) : super(key: key);

  @override
  _FamilyProfileState createState() => _FamilyProfileState();
}

class _FamilyProfileState extends State<FamilyProfile> {
  final FamilyController _familyController = Get.put(FamilyController());
  final _supabase = Supabase.instance.client;
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        _currentUserId = user.id;
        await _familyController.fetchFamilyMembersByUserId(_currentUserId!);
      } else {
        Get.snackbar('Ralat', 'Pengguna belum log masuk');
        // Navigate to login page or handle as needed
      }
    } catch (e) {
      Get.snackbar('Ralat', 'Gagal mendapatkan maklumat pengguna: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddFamilyMemberDialog() async {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final relationshipController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Tambah Ahli Keluarga',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Penuh',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'Nombor Kad Pengenalan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(
                    labelText: 'Hubungan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.people),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    idController.text.isEmpty ||
                    relationshipController.text.isEmpty) {
                  Get.snackbar(
                    'Maklumat Tidak Lengkap',
                    'Sila isikan semua maklumat yang diperlukan',
                    backgroundColor: Colors.red.shade50,
                    colorText: Colors.red.shade900,
                    icon: Icon(Icons.warning, color: Colors.red),
                  );
                  return;
                }

                final newMember = FamilyModel(
                  familymemberName: nameController.text,
                  familymemberIdentification: idController.text,
                  familymemberRelationship: relationshipController.text,
                  familyCreatedAt: DateTime.now(),
                  familyUpdatedAt: DateTime.now(),
                  userId: _currentUserId!,
                );

                _familyController.addFamilyMember(newMember);
                Navigator.pop(context);
              },
              child: Text('Tambah Ahli'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MoonColors.light.hit,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDeleteOptions(FamilyModel member) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Kemaskini Ahli'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditFamilyMemberDialog(member);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Buang Ahli', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(member);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditFamilyMemberDialog(FamilyModel member) async {
    final nameController = TextEditingController(text: member.familymemberName);
    final idController = TextEditingController(
      text: member.familymemberIdentification,
    );
    final relationshipController = TextEditingController(
      text: member.familymemberRelationship,
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kemaskini Ahli Keluarga'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama Penuh'),
                ),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'Nombor Kad Pengenalan',
                  ),
                ),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(labelText: 'Hubungan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    idController.text.isEmpty ||
                    relationshipController.text.isEmpty) {
                  Get.snackbar('Ralat', 'Semua maklumat diperlukan');
                  return;
                }

                final updatedMember = member.copyWith(
                  familymemberName: nameController.text,
                  familymemberIdentification: idController.text,
                  familymemberRelationship: relationshipController.text,
                  familyUpdatedAt: DateTime.now(),
                );

                _familyController.updateFamilyMember(updatedMember);
                Navigator.pop(context);
              },
              child: Text('Kemaskini'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(FamilyModel member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Buang Ahli Keluarga'),
          content: Text(
            'Adakah anda pasti mahu membuang ${member.familymemberName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (member.familyId != null) {
                  _familyController.deleteFamilyMember(member.familyId!);
                }
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Buang'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ahli Keluarga',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black87),
            onPressed: () {
              Get.snackbar(
                'Tentang Profil Keluarga',
                'Tambah dan urus ahli keluarga anda di sini.',
                duration: Duration(seconds: 3),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Obx(() {
                  return _familyController.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : _familyController.familyMembers.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.family_restroom,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tiada ahli keluarga lagi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tambah ahli keluarga anda dengan menekan butang +',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: Icon(Icons.add),
                              label: Text('Tambah Ahli Keluarga'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: _showAddFamilyMemberDialog,
                            ),
                          ],
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Senarai Ahli Keluarga',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._familyController.familyMembers.map((member) {
                              return _buildFamilyMember(
                                member.familymemberName,
                                member.familymemberRelationship,
                                "aktif",
                                onTap: () => _showEditDeleteOptions(member),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                }),
      ),
      floatingActionButton:
          _familyController.familyMembers.isEmpty
              ? null
              : FloatingActionButton.extended(
                onPressed: _showAddFamilyMemberDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Tambah Ahli'),
                backgroundColor: MoonColors.light.hit,
              ),
    );
  }

  Widget _buildFamilyMember(
    String name,
    String relationship,
    String status, {
    Color surfaceColor = Colors.white,
    Color textColor = Colors.black87,
    double bottomPadding = 12,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: MoonColors.light.beerus.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MoonColors.light.hit,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        relationship,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        status.toLowerCase() == "active"
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          status.toLowerCase() == "active"
                              ? Colors.green
                              : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
