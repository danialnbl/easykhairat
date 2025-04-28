import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';

class MemberNew extends StatefulWidget {
  @override
  _MemberNewState createState() => _MemberNewState();
}

class _MemberNewState extends State<MemberNew> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _noKeahlianController = TextEditingController(
    text: '0000',
  );
  final TextEditingController _namaPenuhController = TextEditingController();
  final TextEditingController _icBaruController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tarikhLulusController = TextEditingController();
  final TextEditingController _tarikhLahirController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _poskodController = TextEditingController();
  final TextEditingController _bandarController = TextEditingController();
  final TextEditingController _negeriController = TextEditingController();
  final TextEditingController _pemilikanController = TextEditingController();
  final TextEditingController _phoneRumahController = TextEditingController();
  final TextEditingController _phoneBimbitController = TextEditingController();
  final TextEditingController _surauMasjidController = TextEditingController();

  String? _selectedGelaran;
  String? _selectedMasjid;
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
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daftar Ahli Baru",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Maklumat Ahli",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: Colors.black),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _noKeahlianController,
                                decoration: InputDecoration(
                                  labelText: 'No Keahlian',
                                  helperText:
                                      'Biarkan kosong sekiranya mahu sistem menjanakan no baru.',
                                ),
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedGelaran,
                                hint: Text('Nothing selected'),
                                items:
                                    ['Tuan', 'Puan', 'Encik', 'Cik'].map((
                                      gelaran,
                                    ) {
                                      return DropdownMenuItem(
                                        value: gelaran,
                                        child: Text(gelaran),
                                      );
                                    }).toList(),
                                onChanged:
                                    (value) => setState(
                                      () => _selectedGelaran = value,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'Gelaran',
                                ),
                              ),
                              TextFormField(
                                controller: _namaPenuhController,
                                decoration: InputDecoration(
                                  labelText: '* Nama Penuh',
                                ),

                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  helperText:
                                      'Jika dimasukkan, sistem akan hantar akses automatik.',
                                ),
                              ),
                              SizedBox(height: 16),
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
                                  helperText:
                                      'Kosongkan jika ahli baru. Tarikh hanya untuk ahli sedia ada.',
                                ),
                              ),
                              SizedBox(height: 16),
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
                                label: Text(
                                  'Pilih Gambar',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _tarikhLahirController,
                                readOnly: true,
                                onTap:
                                    () => _selectDate(
                                      context,
                                      _tarikhLahirController,
                                    ),
                                decoration: InputDecoration(
                                  labelText: '*Tarikh Lahir',
                                  hintText: 'DD-MM-YYYY',
                                ),
                              ),
                              TextFormField(
                                controller: _alamatController,
                                decoration: InputDecoration(
                                  labelText: '*Alamat',
                                ),
                              ),
                              TextFormField(
                                controller: _poskodController,
                                decoration: InputDecoration(
                                  labelText: '*Poskod',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              TextFormField(
                                controller: _bandarController,
                                decoration: InputDecoration(
                                  labelText: '*Bandar',
                                ),
                              ),
                              TextFormField(
                                controller: _negeriController,
                                decoration: InputDecoration(
                                  labelText: 'Negeri',
                                ),
                              ),
                              TextFormField(
                                controller: _pemilikanController,
                                decoration: InputDecoration(
                                  labelText: 'Pemilikan',
                                ),
                              ),
                              TextFormField(
                                controller: _phoneRumahController,
                                decoration: InputDecoration(
                                  labelText: 'Nombor Telefon Rumah',
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              TextFormField(
                                controller: _phoneBimbitController,
                                decoration: InputDecoration(
                                  labelText: 'Nombor Telefon Bimbit',
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedMasjid,
                                hint: Text('Nothing selected'),
                                items:
                                    ['Pertubuhan Khairat Kematian'].map((
                                      gelaran,
                                    ) {
                                      return DropdownMenuItem(
                                        value: gelaran,
                                        child: Text(gelaran),
                                      );
                                    }).toList(),
                                onChanged:
                                    (value) =>
                                        setState(() => _selectedMasjid = value),
                                decoration: InputDecoration(
                                  labelText: 'Surau/Masjid',
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Save logic
                                      }
                                    },
                                    icon: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Simpan',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _formKey.currentState!.reset();
                                      _noKeahlianController.clear();
                                      _namaPenuhController.clear();
                                      _icBaruController.clear();
                                      _emailController.clear();
                                      _tarikhLulusController.clear();
                                      _tarikhLahirController.clear();
                                      _alamatController.clear();
                                      _poskodController.clear();
                                      _bandarController.clear();
                                      _negeriController.clear();
                                      _pemilikanController.clear();
                                      _phoneRumahController.clear();
                                      _phoneBimbitController.clear();
                                      _surauMasjidController.clear();
                                      setState(() {
                                        _selectedGelaran = null;
                                        _webImageBytes = null;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.cancel,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Batal',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  color: MoonColors.light.goten,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panduan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 12),
                        Text('• Ruangan bertanda * wajib diisi.'),
                        SizedBox(height: 8),
                        Text("• Sertakan salinan IC untuk di'upload'."),
                        SizedBox(height: 8),
                        Text(
                          "• Bayaran perlu dibuat kepada pegawai selepas mendaftar.",
                        ),
                        SizedBox(height: 8),
                        Text(
                          "• Pastikan anda mendaftar di kariah surau yang betul.",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
