import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/controllers/store_controller.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/controllers/wishlist_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/authentication.dart';
import 'package:mobile_project/services/user_services.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/theme/theme.dart';
import 'package:mobile_project/screens/boarding_screen/onboarding_screen.dart';
import 'package:mobile_project/screens/navbar/nav.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Supabase.initialize(
    url: 'https://bpdpmlqmsoztpckcaeqq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwZHBtbHFtc296dHBja2NhZXFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU1ODM4NzAsImV4cCI6MjA1MTE1OTg3MH0.CfP5HlweWYu3h5oVJM5InzXVWce0OPx-_lEQzPYHLx4',
  );
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );

  Get.lazyPut(() => AuthenticationRepository());
  Get.lazyPut(() => WishlistController());
  Get.lazyPut(() => StoreController());
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
      home: AuthCheck(),
      initialBinding: GeneralBinding(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  final GetStorage storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    bool hasSeenOnboarding = storage.read('hasSeenOnboarding') ?? false;
    if (hasSeenOnboarding) {
      return const Nav();
    } else {
      return const OnboardingScreen();
    }
  }
}

class GeneralBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() =>WishlistController());
    Get.lazyPut(() =>NetworkManager());
    Get.lazyPut(() =>UserController());
    Get.put(UserRepository());
  }
}
