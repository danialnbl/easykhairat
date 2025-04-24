import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';

class Receipts extends StatefulWidget {
  const Receipts({Key? key}) : super(key: key);

  @override
  _ReceiptsState createState() => _ReceiptsState();
}

class _ReceiptsState extends State<Receipts> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MoonColors.light.gohan,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/easyKhairatLogo.png',
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.fitWidth,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: badges.Badge(
                        position: badges.BadgePosition.topEnd(top: -5, end: -5),
                        badgeContent: Text(
                          '3',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            showMenu(
                              color: Colors.white,
                              context: context,
                              position: RelativeRect.fromLTRB(
                                MediaQuery.of(context).size.width - 150,
                                80,
                                16,
                                0,
                              ),
                              items: [
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                      ), // Move icon to the right
                                      child: Icon(
                                        Icons.check,
                                        color:
                                            MoonColors
                                                .light
                                                .bulma, // Change icon color
                                        size: 20,
                                      ),
                                    ),
                                    title: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                      ), // Move text to the right
                                      child: Text(
                                        'Mark all as read',
                                        style: TextStyle(
                                          color:
                                              MoonColors
                                                  .light
                                                  .bulma, // Change text color
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    tileColor:
                                        MoonColors
                                            .light
                                            .beerus, // Change ListTile background color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ), // Optional: Add rounded corners
                                    ),
                                    onTap: () {
                                      // Logic to mark all notifications as read
                                      Navigator.pop(context); // Close the menu
                                    },
                                  ),
                                ),
                                PopupMenuItem(child: Text('Tuntutan Approved')),
                                PopupMenuItem(
                                  child: Text('Sila Bayar Yuran Tertunggak'),
                                ),
                                PopupMenuItem(
                                  child: Text('Ahli keluarga baharu ditambah'),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    // IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receipts',
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
                      _buildFamilyMember(
                        'Yuran Tahunan 2023',
                        "RM 100.00",
                        "Telah Dibayar",
                      ),
                      _buildFamilyMember(
                        'Yuran Tahunan 2024',
                        "RM 100.00",
                        "Telah Dibayar",
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
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
        ),
      ),
    );
  }
}
