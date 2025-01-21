import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/category_controller.dart';
import 'package:get/get.dart';
import 'package:mobile_project/screens/dashboard/category/createCategory.dart';
import 'package:mobile_project/screens/dashboard/category/editCategory.dart';
import 'package:mobile_project/screens/dashboard/category/listCategory.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/layout/grid_layout.dart';

class CategoryManagementScreen extends StatelessWidget {

final CategoryController categoryController = Get.put(CategoryController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Display loading indicator if data is not yet loaded
        if (categoryController.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Display the list of categories
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TGridLayout(
            crossAxisCount: 1,
            physics: const BouncingScrollPhysics(),
            itemCount: categoryController.categories.length,
            mainAxisExtent: 80,
            itemBuilder: (_, index) {
              final category = categoryController.categories[index];

              return Dismissible(
                key: Key(category['id'].toString()),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCategoryScreen(category: category),
                      ),
                    );
                  } else if (direction == DismissDirection.endToStart) {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                          backgroundColor: THelperFunctions.isDarkMode(context)
                            ? Colors.grey[800]
                            : Colors.white,
                        title: const Text("Confirm Delete"),
                        content: Text(
                            "Are you sure you want to delete ${category['name']}?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop(false);
                              await categoryController.deleteCategoryIfNotUsed(
                                  category['id'], category['imagUrl']);
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
                child: ListCategoryScreen(category: category),
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
            MaterialPageRoute(builder: (context) => CreateCategoryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}






















