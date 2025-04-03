import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImage, empNo, fullName, email, phoneNumber, department, role;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empNo = prefs.getString('emp_no') ?? '';
      String firstName = prefs.getString('firstname') ?? '';
      String secondName = prefs.getString('secondname') ?? '';
      profileImage =
          prefs.getString('profile_image') ?? null; // ✅ Load profile image

      fullName = "$firstName $secondName"; // Concatenate first and last name
      email = prefs.getString('email') ?? 'Unknown';
      phoneNumber = prefs.getString('phonenumber') ?? 'Unknown';
      department = prefs.getString('department') ?? 'Unknown';
      role = prefs.getString('role') ?? 'Unknown';
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ Clear all saved data
    Navigator.pushReplacementNamed(context, '/'); // ✅ Navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // 🔹 Profile Picture Section
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange,
                child:
                    profileImage != null && profileImage!.isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            profileImage!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                        : Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ), // ✅ Default person icon
              ),
            ],
          ),

          SizedBox(height: 20),

          // 🔹 Profile Details Section
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _profileDetail(Icons.badge, "Employee No", empNo),
                _profileDetail(Icons.person, "Full Name", fullName),
                _profileDetail(Icons.email, "Email", email),
                _profileDetail(Icons.phone, "Phone Number", phoneNumber),
                _profileDetail(Icons.apartment, "Department", department),
                _profileDetail(Icons.work, "Role", role),
                SizedBox(height: 30),

                // 🔹 Logout Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      "Logout",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Function to Create Profile Detail Row
  Widget _profileDetail(IconData icon, String title, String? value) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value ?? "N/A", style: TextStyle(color: Colors.black87)),
      ),
    );
  }
}
