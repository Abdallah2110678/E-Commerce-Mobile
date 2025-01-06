// views/brand_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/brand_controller.dart';
import 'package:mobile_project/screens/dashboard/brands/createBrand.dart';
import 'package:mobile_project/screens/dashboard/brands/editBrand.dart';
import 'package:mobile_project/screens/dashboard/brands/listBrand.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/enum.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/images/circular_image.dart';
import 'package:mobile_project/widgets/layout/grid_layout.dart';
import 'package:mobile_project/widgets/texts/brand_title_text_with_varified_icon.dart';

class BrandManagementScreen extends StatefulWidget {
  @override
  _BrandManagementScreenState createState() => _BrandManagementScreenState();
}

class _BrandManagementScreenState extends State<BrandManagementScreen> {
  final BrandController brandController = Get.put(BrandController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Display loading indicator if data is not yet loaded
        if (brandController.brands.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Display the list of brands
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TGridLayout(
            crossAxisCount: 1,
            physics: const BouncingScrollPhysics(),
            itemCount: brandController.brands.length,
            mainAxisExtent: 80,
            itemBuilder: (_, index) {
              final brand = brandController.brands[index];

              return Dismissible(
                key: Key(brand['id'].toString()),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                  //  editBrand(index);
                  }
                },
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBrandScreen(brand: brand),
                      ),
                    );
                  } else if (direction == DismissDirection.endToStart) {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: Text(
                            "Are you sure you want to delete ${brand['name']}?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop(false);
                              await brandController.deleteBrandIfNotUsed(
                                  brand['id'], brand['logoUrl']);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  }
                  return false;
                },
                background: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Edit",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Delete",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.delete, color: Colors.white),
                    ],
                  ),
                ),
                child: ListBrandScreen(brand: brand),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add a new brand
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateBrandScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

