import 'dart:convert';
import 'package:final_year_project/screens/admin/add_dependants.dart';
import 'package:final_year_project/screens/admin/edit_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:final_year_project/screens/admin/user_model.dart';
import 'package:final_year_project/screens/admin/user_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final String empNo;

  const UserDetailsScreen({Key? key, required this.empNo}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late UserService _userService;
  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';

  List<dynamic> _dependants = [];
  bool _loadingDependants = true;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _fetchUserDetails().then((_) => _fetchDependants());
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

  Future<void> _fetchDependants() async {
    final url = Uri.parse(
      "https://sanerylgloann.co.ke/EmployeeManagement/get_dependant.php",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"emp_no": widget.empNo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _dependants = data['dependants'];
            _loadingDependants = false;
          });
        } else {
          print("Error: ${data['message']}");
        }
      } else {
        print("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching dependants: $e");
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

          _buildInfoRow("Employee No:", _user!.emp_no ?? "N/A"),
          _buildInfoRow("First Name:", _user!.firstName),
          _buildInfoRow("Second Name:", _user!.secondName),
          _buildInfoRow("Email:", _user!.email),
          _buildInfoRow("Phone Number:", _user!.phoneNumber),
          _buildInfoRow("Role:", _user!.role),
          _buildInfoRow("Status:", _user!.status),
          _buildInfoRow("Department:", _user!.department),

          const SizedBox(height: 16),

          const Text(
            "Dependants:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _loadingDependants
              ? const Center(child: CircularProgressIndicator())
              : _dependants.isEmpty
              ? const Text("No dependants found.")
              : SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dependants.length,
                  itemBuilder: (context, index) {
                    final dep = _dependants[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name: ${dep['name']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Relation: ${dep['relation']}"),
                            const SizedBox(height: 4),
                            Text("Phone: ${dep['phoneNumber'] ?? 'N/A'}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserScreen(user: _user!),
                    ),
                  );
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddDependantScreen(user: _user!),
                    ),
                  );
                },
                child: const Text("Add Dependant"),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Delete functionality coming soon!")),
    );
  }
}
