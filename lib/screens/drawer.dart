import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/screens/dashboard/brands/brandManagement.dart';
import 'package:mobile_project/screens/dashboard/category/categoryManagement.dart';
import 'package:mobile_project/screens/dashboard/dashboard.dart';
import 'package:mobile_project/screens/dashboard/products/createProduct.dart';
import 'package:mobile_project/screens/dashboard/products/productsTable.dart';
import 'package:mobile_project/screens/dashboard/users/users.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/screens/dashboard/users/createUser.dart';

// The main screen with a drawer
class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  // List of screens for navigation
  final List<Widget> _screens = [
    const Dashboard(),
    const AddProductView(),
    CategoryManagementScreen(),
    const ProductTableView(),
    UsersPage(),
    AddUserScreen(),
    BrandManagementScreen(),
  ];

  // List of titles for AppBar
  final List<String> _titles = [
    "Dashboard",
    "Add Product",
    "Categories",
    "Products",
    "Users",
    "Add User",
    "Brand Management"
  ];

  // Currently selected index for the drawer
  int _selectedIndex = 0;

  // Method to handle navigation
// Method to handle navigation
  void _onSelectItem(int index) {
    if (index >= 0 && index < _screens.length) {
      // Check for valid index
      setState(() {
        _selectedIndex = index; // Update the selected index
      });
      Navigator.pop(context); // Close the drawer
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: dark
                    ? Colors.white
                    : Colors.black, // Adjust color for dark and light modes
                size: 30),
            onPressed: () {
              // Open the drawer when the menu icon is tapped
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation Drawer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Drawer items
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: _selectedIndex == 0, // Highlight when active
              onTap: () => _onSelectItem(0),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Product'),
              selected: _selectedIndex == 1, // Highlight when active
              onTap: () => _onSelectItem(1),
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Categorise'),
              selected: _selectedIndex == 2, // Highlight when active
              onTap: () => _onSelectItem(2),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Product'),
              selected: _selectedIndex == 3, // Highlight when active
              onTap: () => _onSelectItem(3),
            ),
            ListTile(
              leading: const Icon(Iconsax.user),
              title: const Text('Users'),
              selected: _selectedIndex == 4, // Highlight when active
              onTap: () => _onSelectItem(4),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add user'),
              selected: _selectedIndex == 5, // Highlight when active
              onTap: () => _onSelectItem(5),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Brands'),
              selected: _selectedIndex == 6, // Highlight when active
              onTap: () => _onSelectItem(6),
            ),
          ],
        ),
      ),
      // Display the selected screen
      body: _screens[_selectedIndex],
    );
  }
}
