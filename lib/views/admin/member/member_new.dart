import 'dart:typed_data';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';

class MemberNew extends StatefulWidget {
  @override
  _MemberNewState createState() => _MemberNewState();
}

class _MemberNewState extends State<MemberNew> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaPenuhController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tarikhLulusController = TextEditingController();
  final TextEditingController _tarikhLahirController = TextEditingController();
  Uint8List? _webImageBytes;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> _pickImageWeb() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final data = await file.readAsBytes();
      setState(() {
        _webImageBytes = data;
      });
    }
  }

  Widget _buildImagePreview() {
    if (_webImageBytes != null) {
      return Image.memory(_webImageBytes!, fit: BoxFit.cover);
    }
    return Center(child: Text("Tiada Gambar"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(title: "Maklumat Ahli", notificationCount: 3),
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
                        MoonBreadcrumbItem(label: Text("Ahli")),
                        MoonBreadcrumbItem(label: Text("Tambah Ahli")),
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
                                "Maklumat Ahli Baru",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _namaPenuhController,
                                decoration: InputDecoration(
                                  labelText: '* Nama Penuh',
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
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _tarikhLulusController,
                                readOnly: true,
                                onTap:
                                    () => _selectDate(
                                      context,
                                      _tarikhLulusController,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'Tarikh Lulus Pendaftaran',
                                  hintText: 'DD-MM-YYYY',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text("Gambar IC"),
                              Container(
                                height: 150,
                                width: 150,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: _buildImagePreview(),
                              ),
                              ElevatedButton.icon(
                                onPressed: _pickImageWeb,
                                icon: Icon(Icons.image, color: Colors.white),
                                label: Text('Pilih Gambar'),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _tarikhLahirController,
                                readOnly: true,
                                onTap:
                                    () => _selectDate(
                                      context,
                                      _tarikhLahirController,
                                    ),
                                decoration: InputDecoration(
                                  labelText: '* Tarikh Lahir',
                                  hintText: 'DD-MM-YYYY',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Save logic
                                      }
                                    },
                                    child: Text("Simpan"),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      _formKey.currentState!.reset();
                                      _namaPenuhController.clear();
                                      _emailController.clear();
                                      _tarikhLulusController.clear();
                                      _tarikhLahirController.clear();
                                      setState(() {
                                        _webImageBytes = null;
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
                            Text("• Sertakan salinan IC untuk di'upload'."),
                            const SizedBox(height: 8),
                            Text(
                              "• Bayaran perlu dibuat kepada pegawai selepas mendaftar.",
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "• Pastikan anda mendaftar di kariah surau yang betul.",
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
