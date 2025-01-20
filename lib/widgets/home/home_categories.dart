import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mobile_project/controllers/home_controller.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/widgets/home/vertical_text_image.dart';

class THomeCategories extends StatelessWidget {
  const THomeCategories({super.key});

  Future<List<Category>> _fetchCategories() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return querySnapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find();

    return FutureBuilder<List<Category>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading categories'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        final categories = snapshot.data!;

        return SizedBox(
          height: 90,
          child: ListView.builder(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final category = categories[index];
              return TVerticalImageText(
                image: category.imagUrl,
                title: category.name,
                onTap: () {
                  // Handle category tap
                  homeController.setSelectedCategory(category.id);
                },
              );
            },
          ),
        );
      },
    );
  }
}
