import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/orderItem.dart';

class Orders {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime timestamp;
  final String address;
  final String city;
  final String postalCode;
  final String phone;

  Orders({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.timestamp,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'phone': phone,
    };
  }
  factory Orders.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Orders(
      id: doc.id,
      userId: data['userId'],
      items: (data['items'] as List).map((item) => OrderItem.fromMap(item)).toList(),
      totalAmount: data['totalAmount'].toDouble(),
      status: data['status'],
      // Handle timestamp that might be stored as String
      timestamp: data['timestamp'] is Timestamp 
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.parse(data['timestamp'].toString()),
      address: data['address'],
      city: data['city'],
      postalCode: data['postalCode'],
      phone: data['phone'],
    );
}
  factory Orders.fromMap(Map<String, dynamic> map) {
    return Orders(
      id: map['id'],
      userId: map['userId'],
      items: List<OrderItem>.from(
          map['items'].map((item) => OrderItem.fromMap(item))),
      totalAmount: map['totalAmount'],
      status: map['status'],
      timestamp: DateTime.parse(map['timestamp']),
      address: map['address'],
      city: map['city'],
      postalCode: map['postalCode'],
      phone: map['phone'],
    );
  }
}