import 'package:badges/badges.dart' as badges;
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/views/user/receipts.dart';
import 'package:easykhairat/views/user/settings.dart';
import 'package:easykhairat/views/user/userPayment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';

class HomePageWidget extends StatefulWidget {
  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final NavigationController navController = Get.find<NavigationController>();
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
          child: SingleChildScrollView(
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
                                'My Khairat Plan',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'MyKasih',
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
                      Column(
                        children: [
                          SizedBox(
                            height:
                                120, // Ensures the carousel has a proper height
                            child: MoonCarousel(
                              itemCount: 3, // Only show 4 items
                              itemExtent: 110,
                              loop: false, // Enables infinite scrolling
                              isCentered: false,
                              clampMaxExtent: true,
                              autoPlay:
                                  false, // Disable autoplay for manual scrolling
                              itemBuilder: (
                                BuildContext context,
                                int itemIndex,
                                int _,
                              ) {
                                // List of preset labels and their corresponding icons
                                List<Map<String, dynamic>> items = [
                                  {
                                    "label": "Receipt",
                                    "icon": MoonIcons.generic_bet_16_light,
                                  },
                                  {
                                    "label": "Support",
                                    "icon": MoonIcons.media_headphones_16_light,
                                  },
                                  {
                                    "label": "Add Family",
                                    "icon": MoonIcons.generic_users_16_light,
                                  },
                                ];

                                return Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    shape: MoonSquircleBorder(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ).squircleBorderRadius(context),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        items[itemIndex]["icon"],
                                        size: 32,
                                        color: MoonColors.light.bulma,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        items[itemIndex]["label"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: MoonColors.light.bulma,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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
                          SizedBox(
                            height: 180,
                            child: OverflowBox(
                              maxWidth: MediaQuery.of(context).size.width,
                              child: MoonCarousel(
                                gap: 32,
                                itemCount: 2,
                                itemExtent:
                                    MediaQuery.of(context).size.width - 32,
                                physics: const PageScrollPhysics(),
                                onIndexChanged:
                                    (int index) =>
                                        setState(() => selectedDot = index),
                                itemBuilder:
                                    (
                                      BuildContext context,
                                      int itemIndex,
                                      int _,
                                    ) => Container(
                                      decoration: ShapeDecoration(
                                        color: MoonColors.light.beerus,
                                        shape: MoonSquircleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ).squircleBorderRadius(context),
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/easyKhairatLogo.png',
                                          width: 50.0,
                                          height: 50.0,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          MoonDotIndicator(
                            selectedDot: selectedDot,
                            dotCount: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Advertisements',
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
                          SizedBox(
                            height: 180,
                            child: OverflowBox(
                              maxWidth: MediaQuery.of(context).size.width,
                              child: MoonCarousel(
                                gap: 32,
                                itemCount: 2,
                                itemExtent:
                                    MediaQuery.of(context).size.width - 32,
                                physics: const PageScrollPhysics(),
                                onIndexChanged:
                                    (int index) => setState(
                                      () => advertisementDot = index,
                                    ),
                                itemBuilder:
                                    (
                                      BuildContext context,
                                      int itemIndex,
                                      int _,
                                    ) => Container(
                                      decoration: ShapeDecoration(
                                        color: MoonColors.light.bulma,
                                        shape: MoonSquircleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ).squircleBorderRadius(context),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          'assets/images/advertisement_${itemIndex + 1}.png',
                                          fit:
                                              BoxFit
                                                  .fill, // Ensures the image fills the container
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          MoonDotIndicator(
                            selectedDot: advertisementDot,
                            dotCount: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required String subtitle}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center items vertically
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MoonColors.light.bulma,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: MoonColors.light.bulma,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              // Center the button horizontally within the row
              child: MoonButton(
                onTap: () {
                  Get.to(() => UserPayment());
                },
                backgroundColor: Color(0xFF12A09B), // Primary button color
                textColor: MoonColors.light.gohan, // Text color
                borderRadius: BorderRadius.circular(50), // Rounded corners
                buttonSize: MoonButtonSize.md, // Medium size button
                label: Text(
                  "Pay Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                showBorder: false, // No border
                showScaleEffect: true, // Adds a click animation effect
              ),
            ),
          ],
        ),
      ),
    );
  }
}
