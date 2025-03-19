import 'package:final_year_project/screens/admin/edit_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/screens/admin/user_model.dart';
import 'package:final_year_project/screens/admin/user_service.dart';


class UserDetailsScreen extends StatefulWidget {
  final String empNo; // 🟢 Employee number to fetch user details

  const UserDetailsScreen({Key? key, required this.empNo}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
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
        _errorMessage = "Failed to load user details.";
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
              ? const Center(child: Text("No user found."))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Profile Image
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _user!.image != null
                                ? NetworkImage(_user!.image!)
                                : const AssetImage("assets/default_user.png")
                                    as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ User Information
                    _buildUserInfo(
                      "Name",
                      "${_user!.firstName} ${_user!.secondName}",
                    ),
                    _buildUserInfo("Email", _user!.email),
                    _buildUserInfo("Phone", _user!.phoneNumber),
                    _buildUserInfo("Role", _user!.role),
                    _buildUserInfo("Status", _user!.status),

                    const SizedBox(height: 20),

                    // ✅ Dependants Section
                    const Text(
                      "Dependants",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _user!.dependants.isEmpty
                        ? const Text("No dependants added.")
                        : Column(
                          children:
                              _user!.dependants
                                  .map(
                                    (dep) => Card(
                                      child: ListTile(
                                        title: Text(dep.name),
                                        subtitle: Text(
                                          "${dep.relation} - ${dep.phoneNumber}",
                                        ),
                                        leading: const Icon(Icons.person),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),

                    const Spacer(),

                    // ✅ Edit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditUserScreen(
                                    user: _user!,
                                  ), // 🟢 Navigates to Edit Screen
                            ),
                          );
                        },
                        child: const Text("Edit User"),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
