import 'package:badges/badges.dart' as badges;
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/views/user/receipts.dart';
import 'package:easykhairat/views/user/settings.dart';
import 'package:easykhairat/views/user/userPayment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
              badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 5),
                badgeContent: Text('3', style: TextStyle(color: Colors.white)),
                child: IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {},
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
                              itemCount: 4, // Only show 4 items
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
                                // List of preset labels
                                List<String> labels = [
                                  "Payment",
                                  "Receipt",
                                  "Support",
                                  "Add Family",
                                ];

                                return Container(
                                  decoration: ShapeDecoration(
                                    color: MoonColors.light.bulma,
                                    shape: MoonSquircleBorder(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ).squircleBorderRadius(context),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      labels[itemIndex], // No numbers, only text labels
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: MoonColors.light.gohan,
                                      ),
                                    ),
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
                                        color: MoonColors.light.bulma,
                                        shape: MoonSquircleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ).squircleBorderRadius(context),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${itemIndex + 1}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: MoonColors.light.gohan,
                                          ),
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
                                      child: Center(
                                        child: Text(
                                          "${itemIndex + 1}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: MoonColors.light.gohan,
                                          ),
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

  Widget _buildCourseSummaryCard() {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Summary',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'An overview of your courses.',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircularIndicator(0.23, 'Course Progress', Colors.orange),
                const SizedBox(width: 16),
                _buildCircularIndicator(0.93, 'Course Grade', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIndicator(double progress, String label, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          percent: progress,
          radius: 50,
          lineWidth: 10,
          animation: true,
          progressColor: color,
          backgroundColor: Colors.grey[300]!,
          center: Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required String subtitle}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: MoonColors.light.bulma,
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
                      color: MoonColors.light.gohan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: MoonColors.light.gohan,
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
                backgroundColor: MoonColors.light.goku, // Primary button color
                textColor: MoonColors.light.bulma, // Text color
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
