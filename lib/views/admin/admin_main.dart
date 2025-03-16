import 'package:easykhairat/views/admin/adminSettings.dart';
import 'package:easykhairat/views/admin/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  _AdminMainState createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  final NavigationController navController = Get.put(NavigationController());

  Widget _buildSidebar() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/easyKhairatLogo.png',
              width: 80.0,
              height: 80.0,
              fit: BoxFit.fitWidth,
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(Icons.home, "Dashboard", 0),
                  _buildNavItem(MoonIcons.generic_user_16_light, "Ahli", 1),
                  _buildNavItem(MoonIcons.shop_wallet_16_light, "Kewangan", 2),
                  _buildNavItem(
                    MoonIcons.media_megaphone_16_light,
                    "Pengumuman",
                    3,
                  ),
                  _buildNavItem(Icons.receipt_long, "Laporan", 4),
                  _buildNavItem(Icons.settings, "Tetapan", 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = navController.selectedIndex.value == index;
    return InkWell(
      onTap: () => navController.changeIndex(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          border:
              isSelected
                  ? Border(left: BorderSide(color: Colors.blue, width: 4))
                  : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color.fromARGB(100, 241, 244, 248),
      body: Row(
        children: [
          if (isWeb) _buildSidebar(),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: navController.selectedIndex.value,
                children: [
                  AdminDashboard(),
                  Center(child: Text('Ahli Screen')),
                  Center(child: Text('Kewangan Screen')),
                  Center(child: Text('Pengumuman Screen')),
                  Center(child: Text('Laporan Screen')),
                  AdminSettings(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          isWeb
              ? null
              : Obx(
                () => BottomNavigationBar(
                  backgroundColor: Colors.white,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(MoonIcons.shop_wallet_16_light),
                      label: 'Fees',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(MoonIcons.generic_bet_16_light),
                      label: 'Report',
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
    );
  }
}
