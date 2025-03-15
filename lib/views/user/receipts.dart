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
                                    'Recipts',
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
                        'Normah binti Jamil',
                        "mother",
                        "active",
                      ),
                      _buildFamilyMember(
                        'Mohamad Yusof bin Omar',
                        "father",
                        "active",
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
            style: TextStyle(fontSize: 12, color: textColor),
          ),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
        ),
      ),
    );
  }
}
