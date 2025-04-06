import 'package:final_year_project/screens/admin/home_screen.dart';
import 'package:final_year_project/screens/admin/training/training_dashboard.dart';
import 'package:final_year_project/screens/admin/user_management.dart';
import 'package:final_year_project/screens/jobs/job_dashboard.dart';
import 'package:final_year_project/screens/leave_management/leave_dashboard.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), // Home Page
    UserManagementDashboardScreen(), // Now loads User Registration Screen
    LeaveDashboard(),
    JobAdDashboard(),
    TrainingDashboard(),
    //InventoryManagementScreen(),
    // LeaveManagementScreen(),
    // NotificationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            _navigateTo(context, "/profile"); // Navigate to Profile
          },
        ),
        title: const Row(
          children: [
            Text(
              "Welcome, Admin ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text("👋", style: TextStyle(fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Navigate to Notices
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Leaves'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Training'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
