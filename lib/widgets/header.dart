import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;

class AppHeader extends StatelessWidget {
  final String title;
  final int notificationCount;
  final VoidCallback? onNotificationPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.notificationCount = 0,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        // badges.Badge(
        //   position: badges.BadgePosition.topEnd(top: 0, end: 5),
        //   badgeContent: Text(
        //     notificationCount.toString(),
        //     style: const TextStyle(color: Colors.white),
        //   ),
        //   child: IconButton(
        //     icon: const Icon(Icons.notifications, color: Colors.grey),
        //     onPressed: onNotificationPressed,
        //   ),
        // ),
      ],
    );
  }
}
