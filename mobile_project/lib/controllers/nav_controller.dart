import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_project/screens/home/home.dart';
import 'package:mobile_project/screens/home/profile.dart';
import 'package:mobile_project/screens/store/store_screen.dart';

class NavController extends GetxController {
  final Rx<int> selectIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const StoreScreen(),
    Container(color: Colors.orange),
    const Profile(),
  ];
}
