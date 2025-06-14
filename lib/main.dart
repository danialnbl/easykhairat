import 'package:easykhairat/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://djeeipnokclsjabwadoq.supabase.co';
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqZWVpcG5va2Nsc2phYndhZG9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0MTE4NDUsImV4cCI6MjA1NTk4Nzg0NX0.sk1UM2xXnUmk6N0jV5UCytHNmWgX9CA6f1uI102uijg';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
      detectSessionInUri: true,
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
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initAppLinks();
    _initAuthStateChange();
    _checkAuthentication();
  }

  Future<void> _initAppLinks() async {
    _appLinks = AppLinks();

    // Listen for deep link events when the app is opened from a link
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Handle the case where the app was opened from a link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Error getting initial app link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    print('Received deep link: $uri');

    // Check if this is a password reset link
    if (uri.path.contains('reset-callback') ||
        uri.fragment.contains('type=recovery')) {
      // Extract the access token and refresh token if available from the URL
      final fragment = uri.fragment;
      if (fragment.isNotEmpty) {
        // Navigate to update password page
        Get.offAllNamed(AppRoutes.updatePassword);
      }
    }
  }

  void _initAuthStateChange() {
    // Listen for auth state changes including password recovery
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      // Handle password recovery event
      if (event == AuthChangeEvent.passwordRecovery) {
        Get.offAllNamed(AppRoutes.updatePassword);
      }
    });
  }

  void _checkAuthentication() {
    // Check if the user is already authenticated
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;

    if (isAuthenticated) {
      // Get the current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId != null) {
        // Check user type from the database
        Supabase.instance.client
            .from('users')
            .select('user_type')
            .eq('user_id', userId)
            .single()
            .then((userData) {
              final userType = userData['user_type'] as String?;

              // Redirect based on user type
              Future.delayed(Duration.zero, () {
                if (userType == 'admin') {
                  Get.offAllNamed(AppRoutes.adminMain);
                } else if (userType == 'user') {
                  Get.offAllNamed(AppRoutes.home);
                } else {
                  // Default route or handle unknown user type
                  Get.offAllNamed(AppRoutes.initial);
                }
              });
            })
            .catchError((error) {
              print('Error fetching user type: $error');
              // Handle error, possibly redirect to login
              Future.delayed(Duration.zero, () {
                Get.offAllNamed(AppRoutes.initial);
              });
            });
      }
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
            borderSide: BorderSide(color: Colors.black),
          ),
          labelStyle: TextStyle(color: Colors.black),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
        ),
      ),
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.pages,
    );
  }

  @override
  void dispose() {
    // No need to dispose AppLinks as it doesn't have a dispose method
    super.dispose();
  }
}
