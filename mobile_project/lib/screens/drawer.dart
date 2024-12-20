import 'package:flutter/material.dart';
import 'package:mobile_project/screens/category_list.dart';
import 'package:mobile_project/screens/dashboard/dashboard.dart';
import 'package:mobile_project/screens/dashboard/products/createProduct.dart';

// The main screen with a drawer
class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  // List of screens for navigation
  final List<Widget> _screens = [
    Dashboard(),
    AddProductView(),
    CategoryManagementPage()
  ];

  // List of titles for AppBar
  final List<String> _titles = [
    "Dashboard",
    "Add Product",
    "Categories",
  ];

  // Currently selected index for the drawer
  int _selectedIndex = 0;

  // Method to handle navigation
  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
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
          ],
        ),
      ),
      // Display the selected screen
      body: _screens[_selectedIndex],
    );
  }
}
