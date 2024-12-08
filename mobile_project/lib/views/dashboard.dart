// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                        Text("Welcome Back Admin!",
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
            GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(context,
                      title: 'Total Sales',
                      value: '\$24,780',
                      icon: Icons.attach_email_rounded,
                      color: Color(0xff4caf50)),
                  _buildStatCard(context,
                      title: 'Total Orders',
                      value: '\$12,780',
                      icon: Icons.shopping_cart_rounded,
                      color: Color(0xff2196f3)),
                  _buildStatCard(context,
                      title: 'Total products',
                      value: '780',
                      icon: Icons.inventory_rounded,
                      color: Color(0xffff5722)),
                  _buildStatCard(context,
                      title: 'Total Customer',
                      value: '\$5,780',
                      icon: Icons.groups_rounded,
                      color: Color(0xff9c2780))
                ]),
            // revenue Section

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Revenue Overview",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TColors.primary),
                          )
                        ])
                  ],
                ),
              ),
            ),
            // recent Orders
            Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Recent Orders",
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: TColors.primary),
                              ),
                              TextButton(
                                  onPressed: () {},
                                  child: Text("view All",
                                      style: GoogleFonts.poppins(
                                          color: TColors.accent)))
                            ]),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )))
          ],
        ),
      ),
    );
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
                  color.withOpacity(0.7),
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
