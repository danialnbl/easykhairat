import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/views/admin/adminSettings.dart';
import 'package:easykhairat/views/admin/admin_dashboard.dart';
import 'package:easykhairat/views/admin/admin_profile.dart';
import 'package:easykhairat/views/admin/kewangan/tetapan_yuran/detail_yuran.dart';
import 'package:easykhairat/views/admin/kewangan/tetapan_yuran/form_yuran.dart';
import 'package:easykhairat/views/admin/kewangan/tuntutan/proses_tuntutan.dart';
import 'package:easykhairat/views/admin/kewangan/tuntutan/tuntutan_ahli.dart';
import 'package:easykhairat/views/admin/kewangan/yuran/proses_yuran.dart';
import 'package:easykhairat/views/admin/kewangan/yuran/yuran_individu.dart';
import 'package:easykhairat/views/admin/kewangan/tetapan_yuran/tetapan_yuran.dart';
import 'package:easykhairat/views/admin/management/add_announce.dart';
import 'package:easykhairat/views/admin/management/detail_announce.dart';
import 'package:easykhairat/views/admin/management/laporan.dart';
import 'package:easykhairat/views/admin/management/manage_announce.dart';
import 'package:easykhairat/views/admin/member/maklumat_ahli.dart';
import 'package:easykhairat/views/admin/member/member_list.dart';
import 'package:easykhairat/views/admin/member/member_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  _AdminMainState createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  final NavigationController navController = Get.put(NavigationController());
  var expandedIndex = (-1).obs;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        Get.offAll(() => const SignInPage());
      }
    });
  }

  Future<void> _checkAuth() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      Get.offAll(() => const SignInPage());
    } else {
      if (mounted) {
        setState(() {
          isAuthenticated = true;
        });
      }
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
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
                  _buildExpandableNavItem(
                    MoonIcons.generic_user_16_light,
                    "Ahli",
                    1,
                    [
                      _buildSubNavItem("Senarai Ahli", 1),
                      _buildSubNavItem("Tambah Ahli", 2),
                    ],
                  ),
                  _buildExpandableNavItem(
                    MoonIcons.shop_wallet_16_light,
                    "Kewangan",
                    3,
                    [
                      _buildSubNavItem("Tetapan Yuran", 3),
                      _buildSubNavItem("Proses Yuran", 4),
                      _buildSubNavItem("Proses Tuntutan", 5),
                    ],
                  ),
                  _buildNavItem(
                    MoonIcons.media_megaphone_16_light,
                    "Pengumuman",
                    6,
                  ),
                  _buildNavItem(Icons.receipt_long, "Laporan", 7),
                  _buildExpandableNavItem(Icons.settings, "Tetapan", 8, [
                    _buildSubNavItem("Profile", 8),
                    MoonMenuItem(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Log Out"),
                              content: Text(
                                "Adakah anda pasti mahu log keluar?",
                              ),
                              actions: [
                                TextButton(
                                  child: Text("Batal"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: Text("Log Keluar"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Get.find<UserController>().signOut();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      backgroundColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      menuItemPadding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 40.0,
                      ),
                      label: Text(
                        "Log Out",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ]),
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

    return MoonMenuItem(
      onTap: () => navController.changeIndex(index),
      backgroundColor:
          isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      menuItemPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      decoration: BoxDecoration(
        border:
            isSelected
                ? Border(
                  left: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 4,
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildExpandableNavItem(
    IconData icon,
    String label,
    int index,
    List<Widget> subItems,
  ) {
    bool isExpanded = expandedIndex.value == index;

    return Column(
      children: [
        MoonMenuItem(
          onTap: () => expandedIndex.value = isExpanded ? -1 : index,
          backgroundColor: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          menuItemPadding: EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          leading: Icon(icon, color: Colors.black),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.black)),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.black,
              ),
            ],
          ),
        ),
        if (isExpanded) Column(children: subItems),
      ],
    );
  }

  Widget _buildSubNavItem(String label, int index) {
    bool isSelected = navController.selectedIndex.value == index;

    return MoonMenuItem(
      onTap: () => navController.changeIndex(index),
      backgroundColor:
          isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      menuItemPadding: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 40.0,
      ), // Increased padding for indentation
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      decoration: BoxDecoration(
        border:
            isSelected
                ? Border(
                  left: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 4,
                  ),
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  MemberList(),
                  MemberNew(),
                  ManageFee(),
                  ProsesYuran(),
                  ProsesTuntutan(),
                  ManageAnnounce(),
                  LaporanPage(),
                  AdminProfile(),
                  YuranIndividu(),
                  FormYuran(),
                  MaklumatAhli(),
                  TuntutanAhli(),
                  DetailYuran(),
                  AddAnnouncement(),
                  DetailAnnouncement(),
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
                  selectedItemColor: Theme.of(context).primaryColor,
                  showUnselectedLabels: true,
                  onTap: navController.changeIndex,
                ),
              ),
    );
  }
}
