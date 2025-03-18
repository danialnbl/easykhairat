import 'package:easykhairat/views/admin/components/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class ManageFee extends StatefulWidget {
  const ManageFee({Key? key}) : super(key: key);

  @override
  _ManageFeeState createState() => _ManageFeeState();
}

class _ManageFeeState extends State<ManageFee> {
  List<Map<String, String>> members = [
    {
      'user_name': 'Yuran Tahunan 2024',
      'user_email': '2024',
      'user_phone_no': '50.00',
      'user_address': '18/3/2024',
      'user_type': 'Admin',
      'user_status': 'Active',
    },
    {
      'user_name': 'Yuran Tahunan 2023',
      'user_email': '2023',
      'user_phone_no': '40.00',
      'user_address': '18/3/2023',
      'user_type': 'Admin',
      'user_status': 'Active',
    },
  ];

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
                title: "Tetapan Yuran",
                notificationCount: 3,
                onNotificationPressed: () {},
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  MoonButton(
                    leading: Icon(
                      MoonIcons.files_add_text_16_light,
                      color: Colors.white,
                    ),
                    buttonSize: MoonButtonSize.md,
                    onTap: () {},
                    label: const Text(
                      'Tetapkan Yuran Baru',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: MoonColors.light.roshi,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildtable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildtable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        color: MoonColors.light.goten,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            columnSpacing: 20.0,
            columns: const [
              DataColumn(
                label: Text(
                  'Tajuk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Untuk Tahun',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Jumlah (RM)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Jana Pada',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows:
                members.map((member) {
                  return DataRow(
                    cells: [
                      DataCell(Text(member['user_name']!)),
                      DataCell(Text(member['user_email']!)),
                      DataCell(Text(member['user_phone_no']!)),
                      DataCell(Text(member['user_address']!)),
                      DataCell(
                        Row(
                          children: [
                            // Add action buttons here
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
