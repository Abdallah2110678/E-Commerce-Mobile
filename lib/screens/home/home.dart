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
  final UserController _controller = Get.put(UserController());
  final StoreController _storeController = Get.find<StoreController>();
  final HomeController _homeController = Get.put(HomeController());

  final RxBool _isLoading = false.obs;

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

  Future<void> _loadUsers() async {
    try {
      _isLoading.value = true;

      // Refresh all necessary data
      await Future.wait([
        _controller.loadUsers(), // Refresh users
        _homeController.fetchAllProducts(), // Refresh products
      ]);
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to refresh the page',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      debugPrint('Error refreshing page: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              TPrimaryHeaderContainer(
                child: Column(
                  children: [
                    // App Bar with Refresh Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: THomeAppBar()),
                        Obx(
                          () => _isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  onPressed: _loadUsers,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Search Bar
                    TSearchContainer(
                      text: 'Search in Store',
                      controller: _searchController,
                      onChanged: (value) {
                        _searchQuery.value = value;
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Categories Section
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

              // Products Section
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    const TPromoSlider(banners: TImages.banners),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Products or Search Results
                    Obx(() {
                      if (_searchQuery.value.isEmpty) {
                        // Show Popular Products
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
                        // Show Search Results
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

                                final products = snapshot.data!.docs
                                    .map((doc) => _storeController
                                        .productFromSnapshot(doc))
                                    .toList();

                                return TGridLayout(
                                  itemCount: products.length,
                                  itemBuilder: (_, index) =>
                                      TProductCardVertical(
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
