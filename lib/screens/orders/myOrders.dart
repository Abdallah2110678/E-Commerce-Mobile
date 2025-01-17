import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/authentication.dart';
import 'package:mobile_project/controllers/order_controller.dart';
import 'package:mobile_project/models/order.dart';
import 'package:mobile_project/screens/orders/orderDetail.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //  final userId = ref.watch(userIdProvider); // Get the authenticated user's ID

    String userId = AuthenticationRepository.instance.authUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: FutureBuilder<List<Orders>>(
        future: ref
            .read(orderControllerProvider)
            .fetchOrdersByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Order #${order.id.substring(0, 8)}'),
                  subtitle: Text(
                    'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to order details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
