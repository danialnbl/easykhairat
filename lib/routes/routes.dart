import 'package:easykhairat/views/admin/admin_main.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:easykhairat/views/user/home.dart';
import 'package:get/get.dart';
import 'package:easykhairat/views/admin/admin_dashboard.dart';
import 'package:easykhairat/views/admin/member/member_list.dart';
import 'package:easykhairat/views/admin/member/member_new.dart';
import 'package:easykhairat/views/admin/kewangan/tetapan_yuran.dart';
import 'package:easykhairat/views/admin/kewangan/proses_yuran.dart';
import 'package:easykhairat/views/admin/adminSettings.dart';

class AppRoutes {
  static const String initial = '/';
  static const String adminMain = '/adminMain';
  static const String dashboard = '/dashboard';
  static const String memberList = '/member-list';
  static const String memberNew = '/member-new';
  static const String manageFee = '/manage-fee';
  static const String prosesYuran = '/proses-yuran';
  static const String adminSettings = '/admin-settings';
  static const String home = '/home';

  static final List<GetPage> pages = [
    GetPage(name: initial, page: () => SignInPage()),
    GetPage(name: adminMain, page: () => AdminMain()),
    GetPage(name: dashboard, page: () => AdminDashboard()),
    GetPage(name: memberList, page: () => MemberList()),
    GetPage(name: memberNew, page: () => MemberNew()),
    GetPage(name: manageFee, page: () => ManageFee()),
    GetPage(name: prosesYuran, page: () => ProsesYuran()),
    GetPage(name: adminSettings, page: () => AdminSettings()),
    GetPage(name: home, page: () => HomePageWidget()),
  ];
}
