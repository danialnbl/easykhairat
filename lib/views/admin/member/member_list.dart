import 'package:easykhairat/views/admin/components/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class MemberList extends StatefulWidget {
  const MemberList({Key? key}) : super(key: key);

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All';

  List<Map<String, String>> members = [
    {
      'user_name': 'Ali Bin Abu',
      'user_email': 'ali@example.com',
      'user_phone_no': '012-3456789',
      'user_address': '87, JALAN SEMARAK 76655 PUCHONG',
      'user_type': 'Admin',
      'user_status': 'Active',
    },
    {
      'user_name': 'Siti Binti Ahmad',
      'user_email': 'siti@example.com',
      'user_phone_no': '019-8765432',
      'user_address': 'Penang',
      'user_type': 'User',
      'user_status': 'Inactive',
    },
    {
      'user_name': 'Hassan Bin Omar',
      'user_email': 'hassan@example.com',
      'user_phone_no': '013-1122334',
      'user_address': 'Johor Bahru',
      'user_type': 'Moderator',
      'user_status': 'Active',
    },
  ];

  List<Map<String, String>> filteredMembers = [];

  @override
  void initState() {
    super.initState();
    filteredMembers = members;
  }

  void filterMembers() {
    setState(() {
      filteredMembers =
          members.where((member) {
            bool matchesSearch = member.values.any(
              (value) => value.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ),
            );
            bool matchesFilter =
                selectedFilter == 'All' ||
                member['user_status'] == selectedFilter;
            return matchesSearch && matchesFilter;
          }).toList();
    });
  }

  void deleteMember(int index) {
    setState(() {
      members.removeAt(index);
      filterMembers();
    });
  }

  void editMember(int index) {
    print("Edit tapped for ${filteredMembers[index]['user_name']}");
    // Add your edit functionality here (e.g., open an edit dialog)
  }

  void viewMember(int index) {
    print("View tapped for ${filteredMembers[index]['user_name']}");
    // Add functionality to display member details in a dialog or new screen
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        color: MoonColors.light.goten,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            columnSpacing: 12.0,
            columns: const [
              DataColumn(
                label: Text(
                  'Nama',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'IC Baru',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Tarikh Daftar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Alamat',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status Ahli',
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
            rows: List.generate(filteredMembers.length, (index) {
              final member = filteredMembers[index];
              return DataRow(
                cells: [
                  DataCell(Text(member['user_name']!)),
                  DataCell(Text(member['user_email']!)),
                  DataCell(Text(member['user_phone_no']!)),
                  DataCell(Text(member['user_address']!)),
                  DataCell(Text(member['user_type']!)),
                  DataCell(Text(member['user_status']!)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.green,
                          ),
                          onPressed: () => viewMember(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editMember(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteMember(index),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(title: "Senarai Ahli", notificationCount: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search member...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => filterMembers(),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedFilter,
                  items:
                      ['All', 'Active', 'Inactive']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedFilter = value;
                      });
                      filterMembers();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTable(),
          ],
        ),
      ),
    );
  }
}
