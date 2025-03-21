import 'package:final_year_project/screens/admin/training/add_training.dart';

import 'package:final_year_project/screens/admin/training/training_list.dart';
import 'package:flutter/material.dart';

class TrainingDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2, // Two items per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildDashboardItem(
              context,
              "View Trainings",
              Icons.list,
              TrainingListScreen(),
            ),
            _buildDashboardItem(
              context,
              "Add Training",
              Icons.add,
              AddTrainingPage(),
            ),
            _buildDashboardItem(
              context,
              "Manage Participants",
              Icons.people,
              AddTrainingPage(),
            ),
            _buildDashboardItem(
              context,
              "Analytics",
              Icons.analytics,
              null,
            ), // Placeholder for future
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget? page,
  ) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Feature coming soon!")));
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
