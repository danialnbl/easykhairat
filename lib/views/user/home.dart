import 'package:badges/badges.dart' as badges;
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/announcement_controller.dart';
import 'package:easykhairat/models/announcementModel.dart';
import 'package:easykhairat/views/user/announcement_details.dart';
import 'package:easykhairat/views/user/create_tuntutan.dart';
import 'package:easykhairat/views/user/receipts.dart';
import 'package:easykhairat/views/user/settings.dart';
import 'package:easykhairat/views/user/userPayment.dart';
import 'package:easykhairat/views/user/user_tuntutan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePageWidget extends StatefulWidget {
  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final NavigationController navController = Get.put(NavigationController());
  int selectedDot = 0;
  int advertisementDot = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MoonColors.light.gohan,
        body: SafeArea(
          child: Obx(
            () => IndexedStack(
              index: navController.selectedIndex.value,
              children: [
                _buildDashboard(context),
                // UserPayment(),
                Receipts(),
                Settings(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              // BottomNavigationBarItem(
              //   icon: Icon(MoonIcons.shop_wallet_16_light),
              //   label: 'Payment',
              // ),
              BottomNavigationBarItem(
                icon: Icon(MoonIcons.generic_bet_16_light),
                label: 'Receipts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: navController.selectedIndex.value,
            unselectedItemColor: MoonColors.light.bulma,
            selectedItemColor: Colors.blue,
            showUnselectedLabels: true,
            onTap: navController.changeIndex,
          ),
        ),
      ),
    );
  }

  bool show = false;

  Widget _buildDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    icon: Icon(Icons.notifications, color: Colors.grey[700]),
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
          // Replace your existing SingleChildScrollView with RefreshIndicator
          child: RefreshIndicator(
            onRefresh: _refreshDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Easykhairat',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Masjid Permatang Badak',
                                  style: GoogleFonts.roboto(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCard(
                                title: 'Total Due',
                                subtitle: 'Pay before 8 April 2025',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'General',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Improve the quick action grid with more visual appeal
                        Container(
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                            shape: MoonSquircleBorder(
                              borderRadius: BorderRadius.circular(
                                16,
                              ).squircleBorderRadius(context),
                            ),
                          ),
                          width: double.infinity,
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            padding: EdgeInsets.all(16),
                            children: [
                              _buildQuickActionTile(
                                icon: MoonIcons.generic_bet_16_light,
                                label: "Receipt",
                                onTap: () => navController.changeIndex(1),
                              ),
                              // _buildQuickActionTile(
                              //   icon: MoonIcons.media_headphones_16_light,
                              //   label: "Support",
                              //   onTap: () {
                              //     // Show support dialog
                              //     Get.dialog(
                              //       AlertDialog(
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(16),
                              //         ),
                              //         title: Row(
                              //           children: [
                              //             Icon(
                              //               Icons.support_agent,
                              //               color: MoonColors.light.bulma,
                              //             ),
                              //             SizedBox(width: 10),
                              //             Text('Contact Support'),
                              //           ],
                              //         ),
                              //         content: Column(
                              //           mainAxisSize: MainAxisSize.min,
                              //           children: [
                              //             ListTile(
                              //               leading: CircleAvatar(
                              //                 backgroundColor: MoonColors
                              //                     .light
                              //                     .bulma
                              //                     .withOpacity(0.1),
                              //                 child: Icon(
                              //                   Icons.phone,
                              //                   color: MoonColors.light.bulma,
                              //                 ),
                              //               ),
                              //               title: Text('Call Admin'),
                              //               subtitle: Text('012-345-6789'),
                              //               onTap: () {
                              //                 // Implement call functionality
                              //                 Get.back();
                              //               },
                              //             ),
                              //             Divider(),
                              //             ListTile(
                              //               leading: CircleAvatar(
                              //                 backgroundColor: MoonColors
                              //                     .light
                              //                     .bulma
                              //                     .withOpacity(0.1),
                              //                 child: Icon(
                              //                   Icons.email,
                              //                   color: MoonColors.light.bulma,
                              //                 ),
                              //               ),
                              //               title: Text('Email'),
                              //               subtitle: Text(
                              //                 'support@easykhairat.com',
                              //               ),
                              //               onTap: () {
                              //                 // Implement email functionality
                              //                 Get.back();
                              //               },
                              //             ),
                              //           ],
                              //         ),
                              //         actions: [
                              //           MoonButton(
                              //             onTap: () => Get.back(),
                              //             backgroundColor: Colors.grey[200],
                              //             textColor: Colors.black87,
                              //             label: Text("Close"),
                              //             borderRadius: BorderRadius.circular(
                              //               50,
                              //             ),
                              //             buttonSize: MoonButtonSize.md,
                              //           ),
                              //         ],
                              //       ),
                              //     );
                              //   },
                              // ),
                              _buildQuickActionTile(
                                icon: Icons.payment,
                                label: "Pay Now",
                                onTap: () => Get.to(() => UserPayment()),
                                highlight: true,
                              ),
                              _buildQuickActionTile(
                                icon: Icons.receipt_long_outlined,
                                label: "Tuntutan",
                                onTap:
                                    () => Get.to(
                                      () => CreateTuntutanPage(),
                                    ), // Updated reference
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Death Announecements',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            GetX<AnnouncementController>(
                              init: AnnouncementController(),
                              builder: (controller) {
                                // Filter announcements for death type only
                                final deathAnnouncements =
                                    controller.announcements
                                        .where(
                                          (a) =>
                                              a.announcementType
                                                  .toLowerCase() ==
                                              'death',
                                        )
                                        .toList();

                                if (controller.isLoading.value) {
                                  return SizedBox(
                                    height: 200, // Increased height
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (deathAnnouncements.isEmpty) {
                                  return SizedBox(
                                    height: 200, // Increased height
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: MoonColors.light.beerus,
                                        shape: MoonSquircleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ).squircleBorderRadius(context),
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.announcement_outlined,
                                              size: 40,
                                              color: Colors.grey[500],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'No death announcements',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  height:
                                      220, // Increased height for image content
                                  child: OverflowBox(
                                    maxWidth: MediaQuery.of(context).size.width,
                                    child: MoonCarousel(
                                      gap: 16,
                                      itemCount: deathAnnouncements.length,
                                      itemExtent:
                                          MediaQuery.of(context).size.width -
                                          32,
                                      physics: const PageScrollPhysics(),
                                      onIndexChanged:
                                          (int index) => setState(
                                            () => selectedDot = index,
                                          ),
                                      itemBuilder: (
                                        BuildContext context,
                                        int itemIndex,
                                        int _,
                                      ) {
                                        final announcement =
                                            deathAnnouncements[itemIndex];
                                        return GestureDetector(
                                          onTap:
                                              () => _showAnnouncementDetails(
                                                announcement,
                                              ),
                                          child: Container(
                                            decoration: ShapeDecoration(
                                              color: MoonColors.light.beerus,
                                              shape: MoonSquircleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ).squircleBorderRadius(
                                                      context,
                                                    ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Image section with conditional display
                                                if (announcement
                                                            .announcementImage !=
                                                        null &&
                                                    announcement
                                                        .announcementImage!
                                                        .isNotEmpty)
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                    child: Image.network(
                                                      announcement
                                                          .announcementImage!,
                                                      height: 100,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            height: 100,
                                                            color:
                                                                Colors
                                                                    .grey[200],
                                                            child: Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              size: 40,
                                                              color:
                                                                  Colors
                                                                      .grey[400],
                                                            ),
                                                          ),
                                                      loadingBuilder: (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress ==
                                                            null)
                                                          return child;
                                                        return Container(
                                                          height: 100,
                                                          color:
                                                              Colors.grey[200],
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    16.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors
                                                                      .red
                                                                      .shade100,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              'Death Notice',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .red
                                                                        .shade800,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            _formatDate(
                                                              announcement
                                                                  .announcementCreatedAt,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        announcement
                                                            .announcementTitle,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        announcement
                                                            .announcementDescription,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines:
                                                            announcement.announcementImage !=
                                                                    null
                                                                ? 2
                                                                : 3,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              final controller = Get.put(
                                AnnouncementController(),
                              );
                              final deathAnnouncements =
                                  controller.announcements
                                      .where(
                                        (a) =>
                                            a.announcementType.toLowerCase() ==
                                            'death',
                                      )
                                      .toList();

                              return MoonDotIndicator(
                                selectedDot: selectedDot,
                                dotCount:
                                    deathAnnouncements.isEmpty
                                        ? 1
                                        : deathAnnouncements.length,
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Announcements',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            GetX<AnnouncementController>(
                              init: AnnouncementController(),
                              initState: (_) {
                                // Fetch announcements when the widget initializes
                                Get.put(
                                  AnnouncementController(),
                                ).fetchAnnouncements();
                              },
                              builder: (controller) {
                                // Filter for general announcements (not death announcements)
                                final generalAnnouncements =
                                    controller.announcements
                                        .where(
                                          (a) =>
                                              a.announcementType
                                                  .toLowerCase() !=
                                              'death',
                                        )
                                        .toList();

                                if (controller.isLoading.value) {
                                  return SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (generalAnnouncements.isEmpty) {
                                  return SizedBox(
                                    height: 180,
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: MoonColors.light.bulma
                                            .withOpacity(0.2),
                                        shape: MoonSquircleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ).squircleBorderRadius(context),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'No general announcements',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  height: 180,
                                  child: OverflowBox(
                                    maxWidth: MediaQuery.of(context).size.width,
                                    child: MoonCarousel(
                                      gap: 32,
                                      itemCount: generalAnnouncements.length,
                                      itemExtent:
                                          MediaQuery.of(context).size.width -
                                          32,
                                      physics: const PageScrollPhysics(),
                                      onIndexChanged:
                                          (int index) => setState(
                                            () => advertisementDot = index,
                                          ),
                                      itemBuilder: (
                                        BuildContext context,
                                        int itemIndex,
                                        int _,
                                      ) {
                                        final announcement =
                                            generalAnnouncements[itemIndex];
                                        return GestureDetector(
                                          onTap:
                                              () => _showAnnouncementDetails(
                                                announcement,
                                              ),
                                          child: Container(
                                            decoration: ShapeDecoration(
                                              color: MoonColors.light.bulma
                                                  .withOpacity(0.2),
                                              shape: MoonSquircleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ).squircleBorderRadius(
                                                      context,
                                                    ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    announcement
                                                        .announcementTitle,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color:
                                                          MoonColors
                                                              .light
                                                              .bulma,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Expanded(
                                                    child: Text(
                                                      announcement
                                                          .announcementDescription,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 4,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Posted on: ${_formatDate(announcement.announcementCreatedAt)}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              final controller = Get.put(
                                AnnouncementController(),
                              );
                              final generalAnnouncements =
                                  controller.announcements
                                      .where(
                                        (a) =>
                                            a.announcementType.toLowerCase() !=
                                            'death',
                                      )
                                      .toList();

                              // Make sure advertisementDot is in valid range
                              if (advertisementDot >=
                                      generalAnnouncements.length &&
                                  generalAnnouncements.isNotEmpty) {
                                advertisementDot = 0;
                              }

                              return MoonDotIndicator(
                                selectedDot:
                                    generalAnnouncements.isEmpty
                                        ? 0
                                        : advertisementDot,
                                dotCount:
                                    generalAnnouncements.isEmpty
                                        ? 1
                                        : generalAnnouncements.length,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required String subtitle}) {
    final FeeController feeController = Get.put(FeeController());
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id ?? '';

    feeController.fetchYuranTertunggak(userId);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.2),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MoonColors.light.bulma.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: MoonColors.light.bulma,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    double totalDue = 0;
                    for (var fee in feeController.yuranTertunggak) {
                      totalDue += fee.feeAmount;
                    }

                    return Row(
                      children: [
                        Text(
                          'RM ${totalDue.toStringAsFixed(2)}',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                totalDue > 0
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (totalDue > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Overdue',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            Center(
              child: MoonButton(
                onTap: () => Get.to(() => UserPayment()),
                backgroundColor: Color(0xFF12A09B),
                textColor: MoonColors.light.gohan,
                borderRadius: BorderRadius.circular(50),
                buttonSize: MoonButtonSize.md,
                label: Row(
                  children: [
                    Icon(Icons.payment, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Pay Now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                showBorder: false,
                showScaleEffect: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAnnouncementDetails(AnnouncementModel announcement) {
    Get.to(
      () => AnnouncementDetailsPage(announcement: announcement),
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 300),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: ShapeDecoration(
            shape: MoonSquircleBorder(
              borderRadius: BorderRadius.circular(
                12,
              ).squircleBorderRadius(Get.context!),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      highlight
                          ? MoonColors.light.bulma.withOpacity(0.2)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow:
                      highlight
                          ? [
                            BoxShadow(
                              color: MoonColors.light.bulma.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                          : null,
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color:
                      highlight
                          ? MoonColors.light.bulma
                          : MoonColors.light.bulma.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                  color: highlight ? MoonColors.light.bulma : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this method to refresh all data on pull-down
  Future<void> _refreshDashboardData() async {
    try {
      // Get the current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // Create a list of futures to execute in parallel
        final futures = [
          // Refresh fee data
          Get.put(FeeController()).fetchYuranTertunggak(userId),

          // Refresh announcements
          Get.put(AnnouncementController()).fetchAnnouncements(),

          // Add any other data refresh methods here
        ];

        // Wait for all refreshes to complete
        await Future.wait(futures);
      }
    } catch (error) {
      print('Error refreshing dashboard data: $error');
      Get.snackbar(
        'Refresh Failed',
        'Unable to refresh data. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
