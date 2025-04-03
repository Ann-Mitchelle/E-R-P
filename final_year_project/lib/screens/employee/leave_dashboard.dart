import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaveHomeScreen extends StatefulWidget {
  @override
  _LeaveHomeScreenState createState() => _LeaveHomeScreenState();
}

class _LeaveHomeScreenState extends State<LeaveHomeScreen> {
  Map<String, int> leaveBalances = {};
  Map<String, int> leaveStats = {};

  @override
  void initState() {
    super.initState();
    _fetchLeaveData();
  }

  Future<void> _fetchLeaveData() async {
    String empNo = "PPP0002"; // Replace with dynamic employee number
    try {
      final balancesUrl =
          "https://sanerylgloann.co.ke/EmployeeManagement/get_leave_balances.php?emp_no=$empNo";
      final statsUrl =
          "https://sanerylgloann.co.ke/EmployeeManagement/get_leave_stats.php?emp_no=$empNo";

      final balancesResponse = await http.get(Uri.parse(balancesUrl));
      final statsResponse = await http.get(Uri.parse(statsUrl));

      if (balancesResponse.statusCode == 200 &&
          statsResponse.statusCode == 200) {
        var balancesJson = jsonDecode(balancesResponse.body);
        var statsJson = jsonDecode(statsResponse.body);

        setState(() {
          leaveBalances = {
            "Annual": balancesJson["leave_balances"][0]["Annual"] ?? 0,
            "Sick": balancesJson["leave_balances"][0]["Sick"] ?? 0,
            "Maternity": balancesJson["leave_balances"][0]["Maternity"] ?? 0,
            "Paternity": balancesJson["leave_balances"][0]["Paternity"] ?? 0,
          };

          leaveStats = {
            "Pending": statsJson["leave_stats"]["Pending"] ?? 0,
            "Approved": statsJson["leave_stats"]["Approved"] ?? 0,
            "Rejected": statsJson["leave_stats"]["Rejected"] ?? 0,
          };
        });
      } else {
        throw Exception("Failed to fetch data from server");
      }
    } catch (e) {
      print("Error fetching leave data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Management"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Quick Stats Section
              Text(
                "Leave Requests Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 10),

              _buildStatsGrid(),

              SizedBox(height: 20),

              Text(
                "Leave Balances",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 10),

              _buildBalancesGrid(),

              SizedBox(height: 30),

              // ✅ Quick Actions Section
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 10),

              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Grid for Quick Stats
  Widget _buildStatsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard(
          "Pending",
          leaveStats["Pending"] ?? 0,
          Colors.orange.shade600,
          Icons.hourglass_empty,
        ),
        _statCard(
          "Approved",
          leaveStats["Approved"] ?? 0,
          Colors.blue.shade600,
          Icons.check_circle,
        ),
        _statCard(
          "Rejected",
          leaveStats["Rejected"] ?? 0,
          Colors.red.shade600,
          Icons.cancel,
        ),
      ],
    );
  }

  // 🔹 Grid for Leave Balances
  Widget _buildBalancesGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallStatCard(
          "Annual",
          leaveBalances["Annual"] ?? 0,
          Colors.blue.shade700,
          Icons.event,
        ),
        _smallStatCard(
          "Sick",
          leaveBalances["Sick"] ?? 0,
          Colors.orange.shade700,
          Icons.local_hospital,
        ),
        _smallStatCard(
          "Maternity",
          leaveBalances["Maternity"] ?? 0,
          Colors.pink.shade600,
          Icons.child_care,
        ),
        _smallStatCard(
          "Paternity",
          leaveBalances["Paternity"] ?? 0,
          Colors.cyan.shade700,
          Icons.family_restroom,
        ),
      ],
    );
  }

  // 🔹 Column for Quick Actions
  Widget _buildQuickActions() {
    return Column(
      children: [
        _quickActionCard("Apply for Leave", Icons.edit, () {
          Navigator.pushNamed(context, '/applyleave');
        }),
        SizedBox(height: 10),
        _quickActionCard("View Applications", Icons.history, () {
          Navigator.pushNamed(context, '/applications');
        }),
      ],
    );
  }

  // 🔹 Quick Action Card
  Widget _quickActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.blue.shade700),
              SizedBox(width: 10),
              Expanded(child: Text(title, style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Large Stats Card Widget
  Widget _statCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        color: color.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              SizedBox(height: 5),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Smaller Leave Balance Cards
  Widget _smallStatCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        color: color.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
