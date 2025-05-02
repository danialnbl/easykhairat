import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:easykhairat/routes/routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionController extends GetxController {
  var isLoggedIn = false.obs;
  var userType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  void checkSession() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      isLoggedIn.value = true;
      _fetchUserType(session.user?.email);
    } else {
      isLoggedIn.value = false;
      Get.offAllNamed(AppRoutes.initial); // Go to login screen if no session
    }
  }

  void _fetchUserType(String? email) async {
    if (email != null) {
      final data =
          await Supabase.instance.client
              .from('users')
              .select('user_type')
              .eq('user_email', email)
              .maybeSingle();

      userType.value = data?['user_type'] ?? 'user';
      _redirectUser(userType.value);
    }
  }

  void _redirectUser(String userType) {
    if (userType == 'admin') {
      Get.offAllNamed(AppRoutes.adminMain);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void logout() async {
    await Supabase.instance.client.auth.signOut();
    checkSession();
  }
}
