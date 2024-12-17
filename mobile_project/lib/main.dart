import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:mobile_project/bindings/general_binding.dart';
import 'package:mobile_project/controllers/signup/authentication.dart';
import 'package:mobile_project/controllers/user/user_repository.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';

import 'package:mobile_project/views/drawer.dart';

import 'package:get/get.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  DrawerScreen(),
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
