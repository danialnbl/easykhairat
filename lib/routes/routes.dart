import 'package:easykhairat/views/admin/admin_main.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:easykhairat/views/auth/reset_password.dart'; // Add this import
import 'package:easykhairat/views/auth/update_password.dart'; // Add this import
import 'package:easykhairat/views/user/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/views/admin/admin_dashboard.dart';
import 'package:easykhairat/views/admin/member/member_list.dart';
import 'package:easykhairat/views/admin/member/member_new.dart';
import 'package:easykhairat/views/admin/kewangan/tetapan_yuran/tetapan_yuran.dart';
import 'package:easykhairat/views/admin/kewangan/yuran/proses_yuran.dart';
import 'package:easykhairat/views/admin/adminSettings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  static const String resetPassword = '/reset-password'; // Add this route
  static const String updatePassword = '/update-password'; // Add this route

  static final List<GetPage> pages = [
    GetPage(
      name: initial,
      page: () => SignInPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: adminMain, page: () => AdminMain()),
    GetPage(name: dashboard, page: () => AdminDashboard()),
    GetPage(name: memberList, page: () => MemberList()),
    GetPage(name: memberNew, page: () => MemberNew()),
    GetPage(name: manageFee, page: () => ManageFee()),
    GetPage(name: prosesYuran, page: () => ProsesYuran()),
    GetPage(name: adminSettings, page: () => AdminSettings()),
    GetPage(name: home, page: () => HomePageWidget()),
    GetPage(
      name: resetPassword,
      page: () => ResetPasswordPage(),
    ), // Add this route
    GetPage(
      name: updatePassword,
      page: () => UpdatePasswordPage(),
    ), // Add this page
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;

    // If trying to access sign-in page while already authenticated, redirect to home
    if (route == AppRoutes.initial && isAuthenticated) {
      return RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}
