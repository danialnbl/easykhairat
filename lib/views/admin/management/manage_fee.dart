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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: MoonColors.light.roshi),
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Tajuk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Untuk Tahun',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Jumlah (RM)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Jana Pada',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          ...members.map((member) {
            return TableRow(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    member['user_name']!,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    member['user_email']!,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    member['user_phone_no']!,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    member['user_address']!,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.green),
                        onPressed: () {
                          // View action
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Edit action
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Delete action
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
