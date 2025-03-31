import 'package:flutter/material.dart';
import 'package:final_year_project/screens/admin/user_model.dart';
import 'package:final_year_project/screens/admin/user_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final String empNo; // Employee Number passed from previous screen

  const UserDetailsScreen({Key? key, required this.empNo}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late UserService _userService;
  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      User user = await _userService.getUserByEmpNo(widget.empNo);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _user == null
              ? const Center(child: Text("User not found"))
              : _buildUserDetails(),
    );
  }

  Widget _buildUserDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  _user!.image.isNotEmpty
                      ? NetworkImage(
                        "https://sanerylgloann.co.ke/EmployeeManagement/user_images/" +
                            _user!.image,
                      )
                      : const AssetImage("assets/default_user.png")
                          as ImageProvider,
            ),
          ),
          const SizedBox(height: 16),

          // User Information
          _buildInfoRow("Employee No:", _user!.emp_no ?? "N/A"),
          _buildInfoRow("First Name:", _user!.firstName),
          _buildInfoRow("Second Name:", _user!.secondName),
          _buildInfoRow("Email:", _user!.email),
          _buildInfoRow("Phone Number:", _user!.phoneNumber),
          _buildInfoRow("Role:", _user!.role),
          _buildInfoRow("Status:", _user!.status),
          _buildInfoRow("Department:", _user!.department),

          const SizedBox(height: 16),

          // Dependants
          if (_user!.dependants.isNotEmpty) ...[
            const Text(
              "Dependants:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dependants:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_user!.dependants.isEmpty)
                  const Text("No dependants listed"),
                ..._user!.dependants.map((dep) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(
                        Icons.family_restroom,
                        color: Colors.blue,
                      ),
                      title: Text(
                        dep.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone: ${dep.phoneNumber}"),
                          Text("Relation: ${dep.relation}"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Edit & Delete Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Edit Screen
                },
                child: const Text("Edit"),
              ),
              ElevatedButton(
                onPressed: () {
                  _deleteUser();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  void _deleteUser() async {
    // TODO: Implement user deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Delete functionality coming soon!")),
    );
  }
}
