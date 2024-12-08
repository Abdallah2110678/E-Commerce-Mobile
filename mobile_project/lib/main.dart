import 'package:flutter/material.dart';
import 'package:mobile_project/bindings/general_binding.dart';
import 'package:mobile_project/views/login/login.dart';
import 'package:get/get.dart';

void main() {
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
      home: const LoginScreen(),
      initialBinding: GeneralBinding(),
    );
  }
}
