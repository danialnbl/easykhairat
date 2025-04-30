import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/views/admin/admin_main.dart';
import 'package:easykhairat/views/admin/kewangan/yuran_individu.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  const supabaseUrl = 'https://djeeipnokclsjabwadoq.supabase.co';
  var supabaseKey = '';

  supabaseKey = dotenv.env['SUPABASE_KEY']!;

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  Get.put(UserController());

  // final supabaseClient = Supabase.instance.client;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyKhairat',
      theme: ThemeData(
        primaryColor: Color(0xFF2BAAAD),
        colorScheme: ColorScheme.light(primary: Color(0xFF2BAAAD)),
      ),

      initialRoute: '/adminMain',
      getPages: [
        GetPage(name: '/', page: () => SignInPage()),
        GetPage(name: '/adminMain', page: () => AdminMain()),
        GetPage(name: '/yuranIndividu', page: () => YuranIndividu()),
      ],
    );
  }
}
