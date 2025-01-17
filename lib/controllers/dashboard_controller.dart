import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/models/order.dart';

class DashboardController extends GetxController {
  var userCount = 0.obs;
  var productCount = 0.obs;
  var orderCount = 0.obs;
  var totalAmount = 0.0.obs;
  final RxList<Orders> orders = <Orders>[].obs;


  final RxBool isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    fetchUserAndProductCount();
  }

  void fetchUserAndProductCount() async {
    userCount.value = await _fetchUserCount();
    productCount.value = await _fetchProductCount();
    orderCount.value = await _fetchOrderCount();
    totalAmount.value = await fetchTotalAmount();
    await fetchLastFiveOrders();
  
  }

  Future<int> _fetchUserCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Users').get();
    return querySnapshot.docs.length;
  }

  Future<int> _fetchProductCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return querySnapshot.docs.length;
  }

  Future<int> _fetchOrderCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    return querySnapshot.docs.length;
  }

  Future<double> fetchTotalAmount() async {
  double totalAmount = 0.0;
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').get();
  for (var doc in querySnapshot.docs) {
    totalAmount += doc['totalAmount'];
  }
  return totalAmount;
}

Future<void> fetchLastFiveOrders() async {
    try {
      isLoading.value = true;
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    .collection('orders')
    .orderBy('timestamp', descending: true)
    .limit(5)
    .get();

      orders.value = querySnapshot.docs
          .map((doc) => Orders.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

   Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      
      // Update local state
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = Orders(
          id: orders[index].id,
          userId: orders[index].userId,
          items: orders[index].items,
          totalAmount: orders[index].totalAmount,
          status: newStatus,
          timestamp: orders[index].timestamp,
          address: orders[index].address,
          city: orders[index].city,
          postalCode: orders[index].postalCode,
          phone: orders[index].phone,
        );
        orders[index] = updatedOrder;
        orders.refresh();
      }
      
      Get.snackbar(
        'Success',
        'Order status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
