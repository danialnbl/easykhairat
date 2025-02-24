import 'package:easykhairat/controller/navigation_controller.dart';
import 'package:easykhairat/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomePageWidget extends StatelessWidget {
  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color.fromARGB(100, 241, 244, 248),
        body: Obx(
          () => IndexedStack(
            index: navController.selectedIndex.value,
            children: [
              _buildDashboard(context),
              Center(child: Text('Profile Screen')),
              Settings(),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: navController.selectedIndex.value,
            selectedItemColor: Colors.blue,
            onTap: navController.changeIndex,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your project status is appearing here.',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildCourseSummaryCard()),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                              title: 'Active Users',
                              subtitle: 'A small summary of your user base.',
                              progress: 0.75,
                              showIndicator: false,
                            ),
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
      color: Color.fromARGB(255, 255, 255, 255),
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

  Widget _buildCard({
    required String title,
    required String subtitle,
    double? progress,
    bool showIndicator = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Color.fromARGB(255, 255, 255, 255),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[600]),
            ),
            if (showIndicator && progress != null) ...[
              const SizedBox(height: 16),
              Center(
                child: CircularPercentIndicator(
                  percent: progress,
                  radius: 50,
                  lineWidth: 10,
                  animation: true,
                  progressColor: Colors.blue,
                  backgroundColor: Colors.grey[300]!,
                  center: Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
