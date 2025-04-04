import 'package:flutter/material.dart';

class LeaveDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Leave Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Quick Statistics Section
                  const Text(
                    "Quick Statistics",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildStatCard(
                        "Employees",
                        "120",
                        Icons.people,
                        Colors.green,
                      ),
                      _buildStatCard(
                        "Upcoming Leaves",
                        "5",
                        Icons.event,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        "Pending Requests",
                        "3",
                        Icons.pending_actions,
                        Colors.red,
                      ),
                      _buildStatCard("Job Ads", "2", Icons.work, Colors.blue),
                      _buildStatCard(
                        "Trainings",
                        "4",
                        Icons.school,
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Quick Actions Section
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildQuickActionTile(
                        "View pending requests",
                        Icons.pending_actions,
                        Colors.red,
                        context,
                        "/adminLeaveRequests",
                      ),
                      _buildQuickActionTile(
                        "View approved Requests",
                        Icons.approval,
                        Colors.green,

                        context,
                        "/leaveRequests",
                      ),
                      _buildQuickActionTile(
                        "View Ongoing Leaves",
                        Icons.person_off,
                        Colors.orange,
                        context,
                        "/addJobAd",
                      ),
                      _buildQuickActionTile(
                        "View Rejected Leaves",
                        Icons.cancel,
                        Colors.red,
                        context,
                        "/addTrainingAd",
                      ),
                      _buildQuickActionTile(
                        "Adjust",
                        Icons.settings,
                        Colors.teal,
                        context,
                        "/adjustSettings",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Helper Function: Statistics Card
  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
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
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
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
