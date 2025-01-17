import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/models/order.dart';

final orderControllerProvider = Provider<OrderController>((ref) {
  return OrderController();
});

class OrderController {
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
}
