import 'package:easykhairat/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://djeeipnokclsjabwadoq.supabase.co';
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqZWVpcG5va2Nsc2phYndhZG9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0MTE4NDUsImV4cCI6MjA1NTk4Nzg0NX0.sk1UM2xXnUmk6N0jV5UCytHNmWgX9CA6f1uI102uijg';

  // Corrected initialization using the available parameters from your FlutterAuthClientOptions
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    // Configure auth options correctly
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Use PKCE auth flow for better security
      autoRefreshToken: true, // Auto refresh the token when needed
      detectSessionInUri:
          true, // Auto detect sessions in URI (handles deep links)
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Check if the user is already authenticated
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;
    if (isAuthenticated) {
      // If authenticated, ensure we go to home not login
      Future.delayed(Duration.zero, () {
        Get.offAllNamed(AppRoutes.home);
      });
    }
  }

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
