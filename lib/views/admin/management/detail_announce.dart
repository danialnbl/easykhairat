import 'package:easykhairat/controllers/announcement_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/models/announcementModel.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
// Replace dart:html import with universal_html
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailAnnouncement extends StatefulWidget {
  @override
  _DetailAnnouncementState createState() => _DetailAnnouncementState();
}

class _DetailAnnouncementState extends State<DetailAnnouncement> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final AnnouncementController announcementController =
      Get.find<AnnouncementController>();
  String _selectedType = 'Umum';

  final supabase = Supabase.instance.client;
  String? _imageUrl;
  String? _fileName;
  Uint8List? _imageBytes;

  final NavigationController navigationController = Get.find();

  @override
  void initState() {
    super.initState();
    final announcement = announcementController.getSelectedAnnouncement();
    if (announcement != null) {
      _titleController.text = announcement.announcementTitle;
      _descriptionController.text = announcement.announcementDescription;
      _selectedType = announcement.announcementType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      await input.onChange.first; // Wait for file selection

      if (input.files!.isEmpty) return;

      final file = input.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;

      setState(() {
        _fileName = file.name;
        _imageBytes = Uint8List.fromList(reader.result as List<int>);
      });

      // Add this check before uploading
      if (supabase.auth.currentUser == null) {
        Get.snackbar(
          'Error',
          'Please login first',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      // Upload to Supabase Storage with error handling
      try {
        final uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        await supabase.storage
            .from('announcement')
            .uploadBinary(
              uniqueFileName,
              _imageBytes!,
              fileOptions: FileOptions(contentType: file.type),
            );

        // Get the public URL
        final imageUrlResponse = supabase.storage
            .from('announcement')
            .getPublicUrl(uniqueFileName);

        setState(() {
          _imageUrl = imageUrlResponse;
        });

        Get.snackbar(
          'Success',
          'Image uploaded successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } catch (storageError) {
        print('Storage error: $storageError');
        Get.snackbar(
          'Error',
          'Failed to upload image. Please ensure you are logged in.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('File picking error: $e');
      Get.snackbar(
        'Error',
        'Failed to select image',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // fetch the announcement details
    AnnouncementModel? announcement =
        announcementController.getSelectedAnnouncement();

    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(title: "Maklumat Pengumuman", notificationCount: 3),
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
                          label: Text("Home"),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(
                          label: Text("Pengumuman"),
                          onTap:
                              () =>
                                  navigationController.selectedIndex.value = 6,
                        ),
                        MoonBreadcrumbItem(label: Text("Maklumat Pengumuman")),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Section: Form
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: MoonColors.light.goku,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Maklumat Pengumuman",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller:
                                    _titleController
                                      ..text =
                                          announcement?.announcementTitle ?? '',
                                decoration: InputDecoration(
                                  labelText: '* Tajuk Pengumuman',
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller:
                                    _descriptionController
                                      ..text =
                                          announcement
                                              ?.announcementDescription ??
                                          '',
                                decoration: InputDecoration(
                                  labelText: '* Keterangan',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 5,
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value:
                                    announcement?.announcementType ??
                                    _selectedType,
                                decoration: InputDecoration(
                                  labelText: '* Jenis Pengumuman',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    ['Umum', 'Kematian']
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                },
                                validator:
                                    (value) =>
                                        value == null ? 'Wajib dipilih' : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Gambar Pengumuman",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              // Display the image if available
                              Container(
                                child:
                                    announcement?.announcementImage != null
                                        ? Image.network(
                                          announcement?.announcementImage ?? "",
                                        )
                                        : Text(
                                          "Tiada gambar dipilih",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Update Gambar Pengumuman",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _pickImage,
                                        icon: Icon(Icons.upload),
                                        label: Text("Pilih Gambar"),
                                      ),
                                      if (_fileName != null) ...[
                                        const SizedBox(width: 8),
                                        Text(_fileName!),
                                        IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () async {
                                            if (_imageUrl != null) {
                                              try {
                                                // Extract file name from URL
                                                final fileName =
                                                    _imageUrl!.split('/').last;
                                                // Delete from Supabase Storage
                                                await supabase.storage
                                                    .from('announcement')
                                                    .remove([fileName]);

                                                setState(() {
                                                  _imageUrl = null;
                                                  _fileName = null;
                                                  _imageBytes = null;
                                                });
                                              } catch (e) {
                                                print(
                                                  'Error deleting image: $e',
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (_imageBytes != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        try {
                                          // Get current user's admin ID from Supabase auth
                                          final currentUser =
                                              supabase.auth.currentUser;
                                          if (currentUser == null) {
                                            Get.snackbar(
                                              'Error',
                                              'Please login first',
                                              backgroundColor: Colors.red
                                                  .withOpacity(0.1),
                                              colorText: Colors.red,
                                            );
                                            return;
                                          }

                                          // Get the existing announcement
                                          final existingAnnouncement =
                                              announcementController
                                                  .getSelectedAnnouncement();
                                          if (existingAnnouncement == null) {
                                            Get.snackbar(
                                              'Error',
                                              'No announcement selected for update',
                                              backgroundColor: Colors.red
                                                  .withOpacity(0.1),
                                              colorText: Colors.red,
                                            );
                                            return;
                                          }

                                          // Create updated announcement maintaining original ID and creation date
                                          final updatedAnnouncement = AnnouncementModel(
                                            announcementId:
                                                existingAnnouncement
                                                    .announcementId,
                                            announcementTitle:
                                                _titleController.text,
                                            announcementDescription:
                                                _descriptionController.text,
                                            announcementType: _selectedType,
                                            announcementCreatedAt:
                                                existingAnnouncement
                                                    .announcementCreatedAt, // Preserve original creation date
                                            announcementUpdatedAt:
                                                DateTime.now(), // Update the modified date
                                            announcementImage:
                                                _imageUrl ??
                                                existingAnnouncement
                                                    .announcementImage,
                                            adminId:
                                                existingAnnouncement.adminId,
                                          );

                                          // Update announcement using the controller
                                          await announcementController
                                              .updateAnnouncement(
                                                updatedAnnouncement,
                                              );

                                          // Show success message and navigate back
                                          Get.snackbar(
                                            'Success',
                                            'Announcement updated successfully',
                                            backgroundColor: Colors.green
                                                .withOpacity(0.1),
                                            colorText: Colors.green,
                                          );
                                          Get.back();
                                        } catch (e) {
                                          print(
                                            'Error updating announcement: $e',
                                          );
                                          Get.snackbar(
                                            'Error',
                                            'Failed to update announcement',
                                            backgroundColor: Colors.red
                                                .withOpacity(0.1),
                                            colorText: Colors.red,
                                          );
                                        }
                                      }
                                    },
                                    child: Text("Kemaskini"),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _titleController.text =
                                            announcement?.announcementTitle ??
                                            '';
                                        _descriptionController.text =
                                            announcement
                                                ?.announcementDescription ??
                                            '';
                                        _selectedType =
                                            announcement?.announcementType ??
                                            'General';
                                        _imageUrl = null;
                                        _fileName = null;
                                        _imageBytes = null;
                                      });
                                    },
                                    child: Text("Batal"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right Section: Guidelines
                  Expanded(
                    flex: 3,
                    child: Card(
                      color: MoonColors.light.goku,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Panduan",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Text("• Ruangan bertanda * wajib diisi."),
                            const SizedBox(height: 8),
                            Text(
                              "• Pengumuman 'Important' akan dipaparkan di bahagian atas.",
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "• Sila pastikan maklumat yang diisi adalah tepat.",
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "• Pengumuman akan dipaparkan mengikut tarikh terkini.",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
