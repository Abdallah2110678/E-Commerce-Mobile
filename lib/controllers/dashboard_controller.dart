
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class DashboardController extends GetxController {
var userCount = 0.obs;
  var productCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserAndProductCount();
  }

  void fetchUserAndProductCount() async {
    userCount.value = await _fetchUserCount();
    productCount.value = await _fetchProductCount();
  }

  Future<int> _fetchUserCount() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users').get();
    return querySnapshot.docs.length;
  }

  Future<int> _fetchProductCount() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('products').get();
    return querySnapshot.docs.length;
  }


}