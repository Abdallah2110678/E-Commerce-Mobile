import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_project/models/order.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Orders order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.md,
                          vertical: TSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          borderRadius:
                              BorderRadius.circular(TSizes.borderRadiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(order.status),
                              color: Colors.white,
                            ),
                            const SizedBox(width: TSizes.sm),
                            Text(
                              order.status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        'Ordered on ${DateFormat.yMMMd().add_jm().format(order.timestamp)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Shipping Address Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping Address',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        "Address: ${order.address}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        'City:  ${order.city}, ${order.postalCode}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        'Postal Code ${order.postalCode}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        'Phone:  ${order.phone}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Order Items
              Text(
                'Order Items',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                    child: Padding(
                      padding: const EdgeInsets.all(TSizes.md),
                      child: Row(
                        children: [
                          TRoundedImage(
                            isNetworkImage: true,
                            imageUrl: item.thumbnailUrl,
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(TSizes.sm),
                            backgroundColor: TColors.light,
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                    height: TSizes.spaceBtwItems / 2),
                                Text(
                                  'Quantity: ${item.quantity}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: TColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('\$${order.totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(height: TSizes.spaceBtwItems * 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: TColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
