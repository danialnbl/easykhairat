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
        Get.snackbar('Error', 'User not logged in');
        // Navigate to login page or handle as needed
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get user: $e');
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
          title: Text('Add Family Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'Identification Number',
                  ),
                ),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(labelText: 'Relationship'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    idController.text.isEmpty ||
                    relationshipController.text.isEmpty) {
                  Get.snackbar('Error', 'All fields are required');
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
              child: Text('Add'),
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
                title: Text('Edit Member'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditFamilyMemberDialog(member);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete Member',
                  style: TextStyle(color: Colors.red),
                ),
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
          title: Text('Edit Family Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'Identification Number',
                  ),
                ),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(labelText: 'Relationship'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    idController.text.isEmpty ||
                    relationshipController.text.isEmpty) {
                  Get.snackbar('Error', 'All fields are required');
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
              child: Text('Update'),
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
          title: Text('Delete Family Member'),
          content: Text(
            'Are you sure you want to delete ${member.familymemberName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (member.familyId != null) {
                  _familyController.deleteFamilyMember(member.familyId!);
                }
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Obx(() {
                        return _familyController.isLoading.value
                            ? Center(child: CircularProgressIndicator())
                            : _familyController.familyMembers.isEmpty
                            ? Center(
                              child: Text(
                                'No family members added yet.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
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
                                                'Family Members',
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
                                  ..._familyController.familyMembers.map((
                                    member,
                                  ) {
                                    return _buildFamilyMember(
                                      member.familymemberName,
                                      member.familymemberRelationship,
                                      "active",
                                      onTap:
                                          () => _showEditDeleteOptions(member),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                      }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFamilyMemberDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add family member',
      ),
    );
  }

  Widget _buildFamilyMember(
    String name,
    String relationship,
    String status, {
    Color surfaceColor = Colors.white,
    Color textColor = Colors.black,
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
          label: Text(name, style: TextStyle(fontSize: 16, color: textColor)),
          content: Text(
            relationship,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
          trailing: Text(
            status,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
        ),
      ),
    );
  }
}
