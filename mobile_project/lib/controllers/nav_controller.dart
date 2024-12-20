import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_project/screens/home/home.dart';

class NavController extends GetxController {
  final Rx<int> selectIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    Container(color: Colors.purple),
    Container(color: Colors.orange),
    Container(color: Colors.blue),
  ];
}
