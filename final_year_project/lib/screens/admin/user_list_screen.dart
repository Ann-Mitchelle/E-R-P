import 'package:final_year_project/screens/admin/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/screens/admin/user_service.dart';
import 'package:final_year_project/screens/admin/user_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (error) {
      print("Error while fetching users: $error");
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

  // Generate PDF report of user list
  Future<void> _generateUserReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build:
            (pw.Context context) => [
              pw.Text(
                'User Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Emp No', 'Name', 'Email', 'Department'],
                data:
                    _filteredUsers.map((user) {
                      return [
                        user.emp_no.toString(),
                        '${user.firstName} ${user.secondName}',
                        user.email,
                        user.department,
                      ];
                    }).toList(),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User List"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Report',
            onPressed: _filteredUsers.isEmpty ? null : _generateUserReport,
          ),
        ],
      ),
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
