// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:mobile_project/utils/constants/colors.dart';
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
            
            // revenue Section

          
            // recent Orders
            
          ],
        ),
      ),
    );
  }


}
