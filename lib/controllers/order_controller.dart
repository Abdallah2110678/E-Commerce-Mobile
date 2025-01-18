import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/models/order.dart';
import 'package:get/get.dart';

// Providers
final orderControllerProvider = Provider<OrderController>((ref) {
  return OrderController();
});

final userOrdersProvider =
    FutureProvider.family<List<Orders>, String>((ref, userId) async {
  final controller = ref.watch(orderControllerProvider);
  return controller.fetchOrdersByUser(userId);
});

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch orders for a specific user
  // In OrderController class, modify fetchOrdersByUser:
  Future<List<Orders>> fetchOrdersByUser(String userId) async {
    if (userId.isEmpty) {
      print("UserId is empty!");
      throw Exception('User ID is required to fetch orders.');
    }

    try {
      print("Attempting to fetch orders for user: $userId");

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      print(
          "Query executed. Number of documents: ${querySnapshot.docs.length}");

      // Print raw data for debugging
      querySnapshot.docs.forEach((doc) {
        print("Document ID: ${doc.id}");
        print("Document data: ${doc.data()}");
      });

      final orders = querySnapshot.docs
          .map((doc) => Orders.fromMap({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      print("Parsed orders length: ${orders.length}");
      return orders;
    } catch (e) {
      print('Error fetching orders for user $userId: $e');
      print('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to fetch orders.');
    }
  }

  // Create a new order
  Future<void> createOrder(Orders order) async {
    if (order.id.isEmpty) {
      throw Exception('Order ID is required to create an order.');
    }

    try {
      await _firestore.collection('orders').doc(order.id).set(order.toMap());
    } catch (e) {
      print('Error creating order ${order.id}: $e');
      throw Exception('Failed to create order.');
    }
  }

  // Update an existing order
  Future<void> updateOrder(Orders order) async {
    if (order.id.isEmpty) {
      throw Exception('Order ID is required to update an order.');
    }

    try {
      await _firestore.collection('orders').doc(order.id).update(order.toMap());
    } catch (e) {
      print('Error updating order ${order.id}: $e');
      throw Exception('Failed to update order.');
    }
  }

  // Delete an order
  Future<void> deleteOrder(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID is required to delete an order.');
    }

    try {
      await _firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      print('Error deleting order $orderId: $e');
      throw Exception('Failed to delete order.');
    }
  }

  // Fetch a single order by ID
  Future<Orders> fetchOrderById(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID is required to fetch an order.');
    }

    try {
      final docSnapshot =
          await _firestore.collection('orders').doc(orderId).get();

      if (docSnapshot.exists) {
        return Orders.fromMap({
          ...docSnapshot.data() as Map<String, dynamic>,
          'id': docSnapshot.id,
        });
      } else {
        throw Exception('Order not found.');
      }
    } catch (e) {
      print('Error fetching order $orderId: $e');
      throw Exception('Failed to fetch order.');
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
