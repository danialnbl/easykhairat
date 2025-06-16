import 'dart:math'; // Add this import for the min function
import 'package:badges/badges.dart' as badges;
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/announcement_controller.dart';
import 'package:easykhairat/models/announcementModel.dart';
import 'package:easykhairat/views/user/announcement_details.dart';
import 'package:easykhairat/views/user/create_tuntutan.dart';
import 'package:easykhairat/views/user/list_tuntutan.dart';
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
  // Use RxInt instead of int for reactive updates
  final RxInt selectedDot = 0.obs;
  final RxInt advertisementDot = 0.obs;

  @override
  void initState() {
    super.initState();
    // Reset indices when announcements data changes
    final announcementController = Get.put(AnnouncementController());
    ever(announcementController.announcements, (_) {
      selectedDot.value = 0;
      advertisementDot.value = 0;
    });
  }

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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Halaman'),
              // BottomNavigationBarItem(
              //   icon: Icon(MoonIcons.shop_wallet_16_light),
              //   label: 'Payment',
              // ),
              BottomNavigationBarItem(
                icon: Icon(MoonIcons.generic_bet_16_light),
                label: 'Resit',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Tetapan',
              ),
            ],
            currentIndex: navController.selectedIndex.value,
            unselectedItemColor: MoonColors.light.bulma,
            selectedItemColor: Color(0xFF2BAAAD),
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
            ],
          ),
        ),
        Expanded(
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
                              child: _buildCard(title: 'Jumlah Tunggakan'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Ciri Utama',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Improve the quick action grid with more visual appeal
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
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
                                childAspectRatio:
                                    constraints.maxWidth /
                                    (constraints.maxWidth * 1.1),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                padding: EdgeInsets.all(16),
                                children: [
                                  _buildQuickActionTile(
                                    icon: MoonIcons.generic_bet_16_light,
                                    label: "Resit Pembayaran",
                                    onTap: () => navController.changeIndex(1),
                                  ),
                                  _buildQuickActionTile(
                                    icon: Icons.payment,
                                    label: "Bayar Sekarang",
                                    onTap: () => Get.to(() => UserPayment()),
                                  ),
                                  _buildQuickActionTile(
                                    icon: Icons.receipt_long_outlined,
                                    label: "Tuntutan",
                                    onTap:
                                        () => Get.to(() => ListTuntutanPage()),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Pengumuman Kematian',
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
                                              'kematian',
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
                                              'Tiada pengumuman kematian',
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
                                      onIndexChanged: (int index) {
                                        final deathAnnouncements =
                                            controller.announcements
                                                .where(
                                                  (a) =>
                                                      a.announcementType
                                                          .toLowerCase() ==
                                                      'kematian',
                                                )
                                                .toList();
                                        if (index >= 0 &&
                                            index < deathAnnouncements.length) {
                                          selectedDot.value = index;
                                        }
                                      },
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
                                              color: Colors.white,
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
                                                              'Pengumuman Kematian',
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
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Pengumuman',
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
                                              'kematian',
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
                                          'Tiada pengumuman am',
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
                                  height:
                                      220, // Increased height for image content
                                  child: OverflowBox(
                                    maxWidth: MediaQuery.of(context).size.width,
                                    child: MoonCarousel(
                                      gap: 16,
                                      itemCount: generalAnnouncements.length,
                                      itemExtent:
                                          MediaQuery.of(context).size.width -
                                          32,
                                      physics: const PageScrollPhysics(),
                                      onIndexChanged: (int index) {
                                        advertisementDot.value = index;
                                      },
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
                                              color: Colors.white,
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
                                                              color: MoonColors
                                                                  .light
                                                                  .bulma
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              'Pengumuman',
                                                              style: TextStyle(
                                                                color:
                                                                    MoonColors
                                                                        .light
                                                                        .bulma,
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
                            // Obx(() {
                            //   final controller = Get.put(
                            //     AnnouncementController(),
                            //   );
                            //   final generalAnnouncements =
                            //       controller.announcements
                            //           .where(
                            //             (a) =>
                            //                 a.announcementType.toLowerCase() !=
                            //                 'kematian',
                            //           )
                            //           .toList();

                            //   // Make sure advertisementDot is in valid range
                            //   if (advertisementDot.value >=
                            //           generalAnnouncements.length &&
                            //       generalAnnouncements.isNotEmpty) {
                            //     advertisementDot.value = 0;
                            //   }

                            //   return MoonDotIndicator(
                            //     selectedDot:
                            //         generalAnnouncements.isEmpty
                            //             ? 0
                            //             : min(
                            //               advertisementDot.value,
                            //               generalAnnouncements.length - 1,
                            //             ),
                            //     dotCount:
                            //         generalAnnouncements.isEmpty
                            //             ? 1
                            //             : generalAnnouncements.length,
                            //   );
                            // }),
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

  Widget _buildCard({required String title}) {
    final FeeController feeController = Get.put(FeeController());
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id ?? '';

    feeController.fetchYuranTertunggak(userId);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.2),
      color: Color(0xFF2BAAAD), // Changed to main teal color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title in white with increased font size
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 16, // Increased font size
                fontWeight: FontWeight.w500,
                color: Colors.white, // High contrast white text
              ),
            ),
            const SizedBox(height: 8),
            // Row for amount and button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amount in white with larger font
                Obx(() {
                  double totalDue = 0;
                  for (var fee in feeController.yuranTertunggak) {
                    totalDue += fee.feeAmount;
                  }

                  return Text(
                    'RM ${totalDue.toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Changed to white text
                    ),
                  );
                }),
                // Pay Bill button with rounded corners and contrasting color
                ElevatedButton(
                  onPressed: () => Get.to(() => UserPayment()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // White background for contrast
                    foregroundColor: Color(0xFF2BAAAD), // Teal text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ), // Slightly larger padding
                  ),
                  child: Text(
                    'Bayar Yuran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ), // Larger text
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 8),
            // // Subtitle in lighter white/gray
            // Text(
            //   subtitle,
            //   style: GoogleFonts.roboto(
            //     fontSize: 12,
            //     color: Colors.white70, // Slightly transparent white
            //   ),
            // ),
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
        'Gagal Menyegarkan',
        'Tidak dapat menyegarkan data. Sila periksa sambungan anda.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
