import 'package:final_year_project/screens/admin/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/screens/admin/user_service.dart';
import 'package:final_year_project/screens/admin/user_model.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  // Fetch all users from the backend
  Future<void> _fetchUsers() async {
    try {
      List<User> users = await _userService.getAllUsers();
      print("Fetched users: $users");
      setState(() {
        _users = users;
        _filteredUsers = users; // Initially, show all users
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load users")));
    }
  }

  // Filter users based on search input
  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers =
          _users.where((user) {
            return user.firstName.toLowerCase().contains(query) ||
                user.secondName.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query) ||
                user.department.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User List")),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Users",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // User List
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                    ? Center(child: Text("No users found"))
                    : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        User user = _filteredUsers[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  user.image.isNotEmpty
                                      ? NetworkImage(user.image)
                                      : AssetImage('assets/images/image.png')
                                          as ImageProvider,
                            ),
                            title: Text("${user.firstName} ${user.secondName}"),
                            subtitle: Text(user.email),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navigate to user details screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => UserDetailsScreen(
                                        empNo: user.emp_no.toString(),
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
