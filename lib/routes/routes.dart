import 'package:easykhairat/views/admin/admin_main.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:easykhairat/views/auth/reset_password.dart';
import 'package:easykhairat/views/auth/update_password.dart';
import 'package:easykhairat/views/user/home.dart';
import 'package:easykhairat/views/user/payment_success.dart';
import 'package:easykhairat/views/user/payment_failure.dart';
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
  static const String resetPassword = '/reset-password';
  static const String updatePassword = '/update-password';
  static const String paymentSuccess = '/payment-success';
  static const String paymentFailure = '/payment-failure';

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
    GetPage(name: resetPassword, page: () => ResetPasswordPage()),
    GetPage(name: updatePassword, page: () => UpdatePasswordPage()),
    GetPage(
      name: paymentSuccess,
      page:
          () => PaymentSuccessPage(
            amount: Get.arguments?['amount'] ?? '0.00',
            description: Get.arguments?['description'] ?? '',
            billCode: Get.arguments?['billCode'] ?? '',
            transactionId: Get.arguments?['transactionId'] ?? '',
          ),
    ),
    GetPage(
      name: paymentFailure,
      page:
          () => PaymentFailurePage(
            amount: Get.arguments?['amount'] ?? '0.00',
            description: Get.arguments?['description'] ?? '',
            billCode: Get.arguments?['billCode'] ?? '',
            errorMessage:
                Get.arguments?['errorMessage'] ??
                'Pembayaran tidak dapat diproses',
          ),
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;

    if (route == AppRoutes.initial && isAuthenticated) {
      return RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}
