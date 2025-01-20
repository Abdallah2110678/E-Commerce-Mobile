import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/home_controller.dart';
import 'package:mobile_project/controllers/store_controller.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/models/role.dart';
import 'package:mobile_project/screens/All_product/All_Product%20_Screen.dart';
import 'package:mobile_project/screens/chat/Admin_List.dart';
import 'package:mobile_project/screens/chat/Chat_Screen.dart';
import 'package:mobile_project/widgets/home/home_app_bar.dart';
import 'package:mobile_project/widgets/home/home_categories.dart';
import 'package:mobile_project/widgets/home/primary_header_container.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/widgets/home/promo_slider.dart';
import 'package:mobile_project/widgets/home/search_container.dart';
import 'package:mobile_project/widgets/home/section_heading.dart';
import 'package:mobile_project/widgets/layout/grid_layout.dart';
import 'package:mobile_project/widgets/products/product_cards/product_card_vertical.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final StoreController _storeController = Get.find<StoreController>();
  final HomeController _homeController = Get.put(HomeController());
  Future<String?> _getAdminEmail() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Role', isEqualTo: 'admin')
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('Email');
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching admin email: $e');
      return null;
    }
  }

  Future<Role> _getUserRole(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final role = snapshot.docs.first['Role'] as String?;
        if (role == 'admin') {
          return Role.admin;
        }
      }
      return Role.user;
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return Role.user;
    }
  }

  void _navigateToChat(BuildContext context, String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email.')),
      );
      return;
    }

    final role = await _getUserRole(email);

    if (role == Role.admin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserListScreen(
            onUserSelected: (userEmail) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    currentUserEmail: email,
                    targetEmail: userEmail,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      final adminEmail = await _getAdminEmail();
      if (adminEmail != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUserEmail: email,
              targetEmail: adminEmail,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No admin available for chat.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  const THomeAppBar(),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  TSearchContainer(
                    text: 'Search in Store',
                    controller: _searchController,
                    onChanged: (value) {
                      _searchQuery.value = value; // Update search query
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [
                        TSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: TSizes.spaceBtwSections),
                        THomeCategories(),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  const TPromoSlider(banners: TImages.banners),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Display Products by Search or Default
                  Obx(() {
                    if (_searchQuery.value.isEmpty) {
                      // Show Popular Products if no search query
                      return Column(
                        children: [
                          TSectionHeading(
                            title: 'Popular Products',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllProductsScreen(
                                    products: _homeController.products,
                                  ),
                                ),
                              );
                            },
                            showActionButton: true,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          Obx(() {
                            if (_homeController.products.isEmpty) {
                              return const Center(
                                  child: Text('No products available'));
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: TSizes.sm,
                                mainAxisSpacing: TSizes.sm,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: _homeController.products.length,
                              itemBuilder: (context, index) {
                                return TProductCardVertical(
                                    product: _homeController.products[index]);
                              },
                            );
                          }),
                        ],
                      );
                    } else {
                      // Show Search Results if there is a search query
                      return Column(
                        children: [
                          const SizedBox(height: TSizes.spaceBtwSections),
                          TSectionHeading(
                            title: 'Search Results',
                            onPressed: () {},
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          StreamBuilder<QuerySnapshot>(
                            stream: _storeController
                                .searchProducts(_searchQuery.value),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(TSizes.defaultSpace),
                                    child: Text('No products found'),
                                  ),
                                );
                              }

                              // Convert Firestore documents to Product objects
                              final products = snapshot.data!.docs.map((doc) {
                                return _storeController
                                    .productFromSnapshot(doc);
                              }).toList();

                              // Display products using TGridLayout and TProductCardVertical
                              return TGridLayout(
                                itemCount: products.length,
                                itemBuilder: (_, index) => TProductCardVertical(
                                  product: products[index],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _navigateToChat(context, UserController.instance.user.value.email),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}
