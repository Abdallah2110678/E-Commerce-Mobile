import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/controllers/CartController.dart';
import 'package:mobile_project/controllers/order_controller.dart';
import 'package:mobile_project/models/order.dart';
import 'package:mobile_project/models/orderItem.dart';
import 'package:mobile_project/screens/orders/orderDetail.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final cartItems = ref.read(cartControllerProvider);
      final orderItems = cartItems.entries.map((entry) {
        return OrderItem(
          id: "",
          productId: entry.key,
          title: entry.value.product.title,
          quantity: entry.value.quantity,
          price: entry.value.product.price,
          thumbnailUrl: entry.value.product.thumbnailUrl,
        );
      }).toList();


      final order = Orders(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: "12",
        items: orderItems,
        totalAmount: ref.read(cartControllerProvider.notifier).totalAmount,
        status: 'pending',
        timestamp: DateTime.now(),
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        phone: _phoneController.text,
      );

      // Save order to Firestore
      await ref.read(orderControllerProvider).createOrder(order);

      // Clear cart and navigate to order details
      ref.read(cartControllerProvider.notifier).clearCart();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing order: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(TSizes.defaultSpace),
                      children: [
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
                                ...cartItems.entries.map((entry) {
                                  final item = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: TSizes.spaceBtwItems),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.quantity}x ${item.product.title}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                            '\$${item.totalPrice.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total'),
                                    Text(
                                      '\$${ref.read(cartControllerProvider.notifier).totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: TColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Shipping Information
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(TSizes.defaultSpace),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shipping Information',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                TextFormField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Address',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your address';
                                    }
                                    return null;
                                  },
                                  maxLines: 3,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _cityController,
                                        decoration: const InputDecoration(
                                          labelText: 'City',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: TSizes.spaceBtwItems),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _postalCodeController,
                                        decoration: const InputDecoration(
                                          labelText: 'Postal Code',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Place Order Button
                  Container(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    decoration: BoxDecoration(
                      color: TColors.light,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Place Order',
                              style: TextStyle(color: TColors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}