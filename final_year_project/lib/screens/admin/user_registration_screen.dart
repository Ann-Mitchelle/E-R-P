import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dependant_model.dart';
import 'user_model.dart';
import 'user_service.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  String firstName = "", secondName = "", email = "", phoneNumber = "";
  String department = "IT", role = "user", status = "active", password = "";
  List<Dependant> dependants = [];

  File? _selectedImage;
  Uint8List? _webImageBytes;
  String? _fileName;
  bool _isLoading = false;
  bool _passwordVisible = false;

  final List<String> _departments = [
    "IT",
    "HR",
    "Finance",
    "Marketing",
    "Operations",
  ];
  final List<String> _roles = ["user", "admin"];
  final List<String> _statuses = ["active", "inactive"];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _fileName = pickedFile.name;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _fileName = path.basename(pickedFile.path);
        });
      }
    }
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      User newUser = User(
        emp_no: "",
        firstName: firstName,
        secondName: secondName,
        email: email,
        phoneNumber: phoneNumber,
        department: department,
        role: role,
        status: status,
        password: password,
        image: _fileName ?? "",
        dependants: dependants,
      );

      String responseMessage = await _userService.addUser(
        newUser,
        _webImageBytes,
        _fileName,
        _selectedImage,
        dependants,
      );

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseMessage)));

      if (responseMessage.contains("success")) {
        Navigator.pop(context);
      }
    }
  }

  void _showDependantDialog() {
    String dependantName = "";
    String dependantPhone = "";
    String dependantRelation = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Dependant"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Dependant Name"),
                onChanged: (value) => dependantName = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Dependant Phone"),
                keyboardType: TextInputType.phone,
                onChanged: (value) => dependantPhone = value,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Relation (e.g. Sibling, Parent)",
                ),
                onChanged: (value) => dependantRelation = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (dependantName.isNotEmpty &&
                    dependantPhone.isNotEmpty &&
                    dependantRelation.isNotEmpty) {
                  setState(() {
                    dependants.add(
                      Dependant(
                        id: dependants.length + 1,
                        name: dependantName,
                        phoneNumber: dependantPhone,
                        relation: dependantRelation,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _removeDependant(int index) {
    setState(() {
      dependants.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child:
                      _webImageBytes != null
                          ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                          : _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : Icon(Icons.person, size: 50, color: Colors.grey),
                ),
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
                validator: (value) => value!.isEmpty ? "Enter email" : null,
                onSaved: (value) => email = value!,
              ),

              // Phone Number
              TextFormField(
                decoration: InputDecoration(labelText: "Phone Number"),
                validator:
                    (value) => value!.isEmpty ? "Enter phone number" : null,
                onSaved: (value) => phoneNumber = value!,
              ),

              // Password with Eye Icon
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                  ),
                ),
                obscureText: !_passwordVisible,
                validator: (value) => value!.isEmpty ? "Enter password" : null,
                onSaved: (value) => password = value!,
              ),

              // Department Dropdown
              DropdownButtonFormField(
                value: department,
                items:
                    _departments
                        .map(
                          (dept) =>
                              DropdownMenuItem(value: dept, child: Text(dept)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => department = value!),
                decoration: InputDecoration(labelText: "Department"),
              ),

              // Role Dropdown
              DropdownButtonFormField(
                value: role,
                items:
                    _roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                onChanged: (value) => setState(() => role = value!),
                decoration: InputDecoration(labelText: "Role"),
              ),

              // Status Dropdown
              DropdownButtonFormField(
                value: status,
                items:
                    _statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (value) => setState(() => status = value!),
                decoration: InputDecoration(labelText: "Status"),
              ),

              SizedBox(height: 20),

              // Dependants Section
              Text(
                "Dependants",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...dependants.map(
                (d) => ListTile(
                  title: Text("${d.name} - ${d.relation}"),
                  subtitle: Text(d.phoneNumber),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeDependant(dependants.indexOf(d)),
                  ),
                ),
              ),

              ElevatedButton.icon(
                onPressed: _showDependantDialog,
                icon: Icon(Icons.add),
                label: Text("Add Dependant"),
              ),

              SizedBox(height: 20),

              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _registerUser,
                    child: Text("Register User"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
