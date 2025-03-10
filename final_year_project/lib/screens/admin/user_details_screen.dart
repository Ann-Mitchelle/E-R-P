import 'package:flutter/material.dart';
import 'package:final_year_project/screens/admin/user_service.dart';
import 'package:final_year_project/screens/admin/user_model.dart';

class UserDetailScreen extends StatefulWidget {
  final String empNo; // Use emp_no instead of id

  const UserDetailScreen({Key? key, required this.empNo}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late UserService _userService;
  User? _user;
  bool _isLoading = true;
  String _errorMessage = "";

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
        _errorMessage = "Error fetching user details: $e";
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
              ? Center(
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              )
              : _user == null
              ? const Center(child: Text("User not found"))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _user!.image.isNotEmpty
                        ? Center(
                          child: CircleAvatar(
                            radius: 50,

                            backgroundImage:
                                _user?.image != null && _user!.image.isNotEmpty
                                    ? NetworkImage(_user!.image)
                                    : const AssetImage(
                                          "assets/default_user.png",
                                        )
                                        as ImageProvider,
                          ),
                        )
                        : const Center(child: Icon(Icons.person, size: 100)),
                    const SizedBox(height: 20),
                    Text(
                      "Name: ${_user!.firstName} ${_user!.secondName}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Email: ${_user!.email}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Phone: ${_user!.phoneNumber}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Department: ${_user!.department}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Role: ${_user!.role}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Status: ${_user!.status}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
    );
  }
}
