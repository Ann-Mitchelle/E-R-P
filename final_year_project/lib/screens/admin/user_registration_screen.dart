import 'dart:io'; // Only used for mobile
import 'dart:typed_data'; // Used for web
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // To check if running on web
import 'package:image_picker/image_picker.dart';
import 'package:final_year_project/screens/admin/user_model.dart';
import 'package:final_year_project/screens/admin/user_service.dart';
import 'package:path/path.dart' as path;


class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  // User Details
  String firstName = "";
  String secondName = "";
  String email = "";
  String phoneNumber = "";
  String department = "IT"; // Default department
  String role = "user"; // Default role
  String status = "active";
  String password = "";

  // Image File (for mobile) and Image Bytes (for web)
  File? _selectedImage;
  Uint8List? _webImageBytes;
  String? _fileName;
  bool _isLoading = false;

  // List of Departments
  final List<String> _departments = [
    "IT",
    "HR",
    "Finance",
    "Marketing",
    "Operations",
  ];
  final List<String> _role = ["user", "admin"];
  final List<String> _status = ["active", "inactive"];

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // For Web: Convert image to Uint8List
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _fileName = pickedFile.name;
        });
      } else {
        // For Mobile: Use File
        setState(() {
          _selectedImage = File(pickedFile.path);
          _fileName = path.basename(pickedFile.path);
        });
      }
    }
  }

  // Function to register user
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      User newUser = User(
        id: "", // Backend generates this automatically
        firstName: firstName,
        secondName: secondName,
        email: email,
        phoneNumber: phoneNumber,
        department: department,
        role: role, // Default role
        status: status,
        password: password,
        image: _fileName ?? "", // Store image path
      );

      String responseMessage = await _userService.addUser(
        newUser,
        _webImageBytes, // Use web image bytes
        _fileName, // Use file name
        _selectedImage, // Use file
      );
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseMessage)));
      if (responseMessage.contains("success")) {
        Navigator.pop(context); // Navigate back after successful registration
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Registration")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image Preview (Handles Web & Mobile)
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child:
                      _webImageBytes != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _webImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                          : _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text("No Image Selected"),
                            ],
                          ),
                ),

                SizedBox(height: 10),

                // Image Picker Button
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text("Pick Profile Image"),
                ),

                SizedBox(height: 20),

                // First Name
                TextFormField(
                  decoration: InputDecoration(labelText: "First Name"),
                  validator:
                      (value) => value!.isEmpty ? "Enter first name" : null,
                  onSaved: (value) => firstName = value!,
                ),

                // Second Name
                TextFormField(
                  decoration: InputDecoration(labelText: "Second Name"),
                  validator:
                      (value) => value!.isEmpty ? "Enter second name" : null,
                  onSaved: (value) => secondName = value!,
                ),

                // Email
                TextFormField(
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value!.contains('@') ? null : "Enter valid email",
                  onSaved: (value) => email = value!,
                ),

                // Phone Number
                TextFormField(
                  decoration: InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value!.length >= 10
                              ? null
                              : "Enter valid phone number",
                  onSaved: (value) => phoneNumber = value!,
                ),

                // Department Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Department"),
                  value: department,
                  onChanged: (value) {
                    setState(() {
                      department = value!;
                    });
                  },
                  items:
                      _departments.map((dep) {
                        return DropdownMenuItem(value: dep, child: Text(dep));
                      }).toList(),
                ),
                // Role Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Role"),
                  value: role,
                  onChanged: (value) {
                    setState(() {
                      role = value!;
                    });
                  },
                  items:
                      _role.map((roleItem) {
                        return DropdownMenuItem(
                          value: roleItem,
                          child: Text(roleItem),
                        );
                      }).toList(),
                ),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Status"),
                  value: status,
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                  items:
                      _status.map((statusItem) {
                        return DropdownMenuItem(
                          value: statusItem,
                          child: Text(statusItem),
                        );
                      }).toList(),
                ),

                // Password
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator:
                      (value) =>
                          value!.length >= 6
                              ? null
                              : "Password must be at least 6 characters",
                  onSaved: (value) => password = value!,
                ),

                SizedBox(height: 20),

                // Register Button
                ElevatedButton(
                  onPressed: _registerUser,
                  child: Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
