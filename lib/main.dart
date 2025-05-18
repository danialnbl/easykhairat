import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/routes/routes.dart';
import 'package:easykhairat/views/admin/admin_main.dart';
import 'package:easykhairat/views/admin/kewangan/yuran/yuran_individu.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://djeeipnokclsjabwadoq.supabase.co';
  // Replace this with your actual Supabase anon key
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqZWVpcG5va2Nsc2phYndhZG9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODUwMzk5ODUsImV4cCI6MjAwMDYxNTk4NX0.gQizkBNCJ9Jx1DWAFHDM6vPJKkSj2Cxjf_eKb40vXrA';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

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
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // your preferred color
          ),
          labelStyle: TextStyle(color: Colors.black), // label when focused
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black, // changes the teal cursor globally
        ),
      ),

      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.pages,
    );
  }
}
