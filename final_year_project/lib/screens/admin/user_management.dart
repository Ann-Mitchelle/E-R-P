import 'package:flutter/material.dart';
import 'user_list_screen.dart';
import 'user_registration_screen.dart';

class UserManagementDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Grid Layout for Quick Actions
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two tiles per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildQuickActionTile(
                    "Add User",
                    Icons.person_add,
                    Colors.purple,
                    context,
                    UserRegistrationScreen(),
                  ),
                  _buildQuickActionTile(
                    "View Users",
                    Icons.list,
                    Colors.blue,
                    context,
                    UserListScreen(),
                  ),
                  _buildQuickActionTile(
                    "Edit Users",
                    Icons.edit,
                    Colors.orange,
                    context,
                    UserListScreen(), // Select a user from here to edit
                  ),
                  _buildQuickActionTile(
                    "Settings",
                    Icons.settings,
                    Colors.teal,
                    context,
                    UserListScreen(), // Replace with your settings screen
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper Function: Quick Actions Tile
  Widget _buildQuickActionTile(
    String title,
    IconData icon,
    Color color,
    BuildContext context,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
