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
    final user = AuthenticationRepository.instance.authUser;

    // Debug print
    print("Current user ID: ${user?.uid}");

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You need to log in to view your orders.'),
        ),
      );
    }
    // Watch the orders stream
    final ordersAsyncValue = ref.watch(userOrdersProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the orders
              ref.refresh(userOrdersProvider(user.uid));
            },
          ),
        ],
      ),
      body: ordersAsyncValue.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading orders...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading orders\n${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(userOrdersProvider(user.uid));
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start shopping to see your orders here',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to shop or home screen
                      Navigator.of(context).pushReplacementNamed('/shop');
                    },
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(userOrdersProvider(user.uid));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (order.status != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${order.status}',
                            style: TextStyle(
                              color: _getStatusColor(order.status ?? ''),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
