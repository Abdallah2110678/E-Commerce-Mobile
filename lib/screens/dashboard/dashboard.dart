// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mobile_project/controllers/dashboard_controller.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/screens/orders/orders.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/home/section_heading.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashboardController controller = Get.put(DashboardController());
  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // wellconme section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    TColors.primary,
                    const Color.fromARGB(255, 37, 61, 178)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Welcome ${userController.user.value.fullName}',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 8,
                        ),
                        Text("Here's an overview of store ",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 14)),
                      ]),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.auto_graph_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
            //status secction
            Obx(() {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Total Sales',
                    value: '\$ ${controller.totalAmount.toString()}',
                    icon: Icons.attach_email_rounded,
                    color: Color(0xff4caf50),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Total Orders',
                    value: controller.orderCount.toString(),
                    icon: Icons.shopping_cart_rounded,
                    color: Color(0xff2196f3),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Total products',
                    value: controller.productCount.toString(),
                    icon: Icons.inventory_rounded,
                    color: Color(0xffff5722),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Total Customer',
                    value: controller.userCount.toString(),
                    icon: Icons.groups_rounded,
                    color: Color(0xff9c2780),
                  ),
                ],
              );
            }),
            // revenue Section
            TSectionHeading(
              title: 'Last Orders',
              onPressed: () {
                Get.to(() => Orders());
              },
              showActionButton: true,
            ),
            Obx(() {
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
                                    backgroundColor: THelperFunctions.isDarkMode(context)
                            ? Colors.grey[800]
                            : Colors.white,
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
            // recent Orders
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  color,
                  color.withOpacity(0.5),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(15)),
            child: Stack(children: [
              Positioned(
                  right: -20,
                  top: -20,
                  child: Opacity(
                    opacity: 0.3,
                    child: Icon(
                      icon,
                      size: 80,
                      color: Colors.white,
                    ),
                  )),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ]))); 
  }
}
