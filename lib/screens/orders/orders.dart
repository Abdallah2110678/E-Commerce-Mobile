

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/order_controller.dart';
class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body:Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.orders.isEmpty) {
                return Center(child: Text('No orders found'));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Items')),
                    DataColumn(label: Text('Address')),
                  ],
                  rows: controller.orders.map((order) {
                    return DataRow(
                      cells: [
                        DataCell(Text(order.id.substring(0, 8))),
                        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                            .format(order.timestamp))),
                        DataCell(
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Update Order Status'),
                                  content: DropdownButton<String>(
                                    value: order.status,
                                    items: [
                                      DropdownMenuItem(
                                          value: 'pending',
                                          child: Text('Pending')),
                                      DropdownMenuItem(
                                          value: 'delivered',
                                          child: Text('Delivered')),
                                      DropdownMenuItem(
                                          value: 'cancelled',
                                          child: Text('Cancelled')),
                                    ],
                                    onChanged: (newStatus) {
                                      if (newStatus != null) {
                                        controller.updateOrderStatus(
                                            order.id, newStatus);
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    order.status,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                            Text('\$${order.totalAmount.toStringAsFixed(2)}')),
                        DataCell(Text('${order.items.length} items')),
                        DataCell(Text('${order.address}, ${order.city}')),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
    );
  }
}


  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }