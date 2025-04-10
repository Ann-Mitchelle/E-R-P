import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeDashboard extends StatefulWidget {
  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  String employeeName = "Employee"; // Default if not found
  int _selectedIndex = 0; // For Bottom Navbar

  @override
  void initState() {
    super.initState();
    _loadEmployeeName(); // ✅ Load name on start
  }

  Future<void> _loadEmployeeName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstName = prefs.getString("firstname") ?? "";
    String secondName = prefs.getString("secondname") ?? "";

    setState(() {
      employeeName =
          "$firstName $secondName"
              .trim(); // ✅ Concatenate and remove extra spaces
    });
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('MMMM d, y').format(now); // Example: March 21, 2025
  }

  // Navigation for Bottom Navbar
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break; // Stay on Dashboard
      case 1:
        _navigateTo(context, "/leave_application");
        break;
      case 2:
        _navigateTo(context, "/training");
        break;
      case 3:
        _navigateTo(context, "/jobNotifications");
        break;
      case 4:
        _navigateTo(context, "/applications");
        break;
    }
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade100, // Light blue background
            child: ClipOval(
              child: Image.asset(
                "assets/profile_placeholder.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ); // Default icon
                },
              ),
            ),
          ),
          onPressed: () {
            _navigateTo(context, "/profile");
          },
        ),

        title: const Text(
          "Dashboard",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Greeting
            Text(
              "Hello, $employeeName 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Quick Stats
            _buildQuickStat("📅 Today's Date", _getFormattedDate()),
            _buildQuickStat("🕒 Leave Days Left", "10 days remaining"),
            _buildQuickStat("⏳ Pending Leave Requests", "2 pending"),

            const SizedBox(height: 20),

            // Quick Actions Title
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Grid for Quick Actions
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _buildQuickAction(
                  context,
                  Icons.assignment,
                  "Apply Leave",
                  () => _navigateTo(context, "/applyleave"),
                ),
                _buildQuickAction(
                  context,
                  Icons.notifications,
                  "Check Notifications",
                  () => _navigateTo(context, "/notifications"),
                ),
                _buildQuickAction(
                  context,
                  Icons.history,
                  "View Requests",
                  () => _navigateTo(context, "/applications"),
                ),
                _buildQuickAction(
                  context,
                  Icons.school,
                  "View applications",
                  () => _navigateTo(context, "/myApplications"),
                ),
                _buildQuickAction(
                  context,
                  Icons.help,
                  "Help & Support",
                  () => _navigateTo(context, "/help"),
                ),
              ],
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Apply"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Training"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Apps",
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.blueAccent),
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
    );
  }
}
