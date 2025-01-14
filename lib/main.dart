import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_project/controllers/CartController.dart';
import 'package:mobile_project/controllers/store_controller.dart';

import 'package:mobile_project/controllers/wishlist_controller.dart';
import 'package:mobile_project/screens/Cart/Cart_Screen.dart';
import 'package:provider/provider.dart';
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
    url: 'https://bpdpmlqmsoztpckcaeqq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwZHBtbHFtc296dHBja2NhZXFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU1ODM4NzAsImV4cCI6MjA1MTE1OTg3MH0.CfP5HlweWYu3h5oVJM5InzXVWce0OPx-_lEQzPYHLx4',
  );
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CartController()), // Provide CartController
      ],
      child: const MyApp(),
    ),
  );
  Get.put(AuthenticationRepository());
  Get.put(WishlistController());
  Get.put(StoreController());
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
