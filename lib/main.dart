import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_project/controllers/wishlist_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/authentication.dart';
import 'package:mobile_project/services/user_services.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/theme/theme.dart';
import 'package:mobile_project/screens/boarding_screen/onboarding_screen.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nhinkintdaqetmvxmonu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oaW5raW50ZGFxZXRtdnhtb251Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU0Nzc2OTUsImV4cCI6MjA1MTA1MzY5NX0.SJdpNKFTH4SwYimEpFSuQKFdw3a0yGTkSSh3HRykOkU',
  );
  await Firebase.initializeApp();
  runApp(const MyApp());
  Get.put(AuthenticationRepository());
  Get.put(WishlistController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Project',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: const OnboardingScreen(),
      initialBinding: GeneralBinding(),
    );
  }
}

class GeneralBinding extends Bindings {
  @override
  void dependencies() {
    // Register the AuthenticationRepository
    Get.lazyPut<AuthenticationRepository>(() => AuthenticationRepository());
    // Register NetworkManager
    Get.lazyPut<NetworkManager>(() => NetworkManager());
    Get.lazyPut(() => UserRepository());
  }
}
