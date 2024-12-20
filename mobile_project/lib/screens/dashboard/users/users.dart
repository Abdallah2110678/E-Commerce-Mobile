import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/models/usermodel.dart';

class Users extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<Users> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserController>().loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to Create User Screen
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => CreateUserScreen()),
              // );
            },
          ),
        ],
      ),
      body: Consumer<UserController>(
        builder: (context, userController, child) {
          if (userController.users.isEmpty) {
            return Center(
              child: Text('No users found. Click the + button to add a user.'),
            );
          }

          return ListView.builder(
            itemCount: userController.users.length,
            itemBuilder: (context, index) {
              final user = userController.users[index];
              return ListTile(
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Navigate to Update User Screen with the selected user
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => UpdateUserScreen(user: user),
                        //   ),
                        //);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Confirm before deleting the user
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete User'),
                            content: Text(
                                'Are you sure you want to delete ${user.firstName} ${user.lastName}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Delete the user
                          await context
                              .read<UserController>()
                              .deleteUser(user.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
