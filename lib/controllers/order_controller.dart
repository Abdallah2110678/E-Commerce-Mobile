import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/models/order.dart';
import 'package:get/get.dart';

final orderControllerProvider = Provider<OrderController>((ref) {
  return OrderController();
});

class OrderController extends GetxController {
  Future<List<Orders>> fetchOrdersByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          // Exclude documents with null userId
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs
          .map((doc) => Orders.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching orders for user $userId: ${e.toString()}');
      throw Exception('Failed to fetch orders: ${e.toString()}');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new order
  Future<void> createOrder(Orders order) async {
    try {
      await _firestore.collection('orders').doc(order.id).set(order.toMap());
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Update an existing order
  Future<void> updateOrder(Orders order) async {
    try {
      await _firestore.collection('orders').doc(order.id).update(order.toMap());
    } catch (e) {
      throw Exception('Failed to update order: ${e.toString()}');
    }
  }

  // Delete an order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: ${e.toString()}');
    }
  }

  // Fetch a single order by ID
  Future<Orders> fetchOrderById(String orderId) async {
    try {
      final docSnapshot =
          await _firestore.collection('orders').doc(orderId).get();
      if (docSnapshot.exists) {
        return Orders.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception('Order not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch order: ${e.toString()}');
    }
  }

  var totalAmount = 0.0.obs;
  final RxList<Orders> orders = <Orders>[].obs;

  final RxBool isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
  }
  
  Future<void> fetchAllOrders() async {
    try {
      isLoading.value = true;
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .get();

      orders.value =
          querySnapshot.docs.map((doc) => Orders.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
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
