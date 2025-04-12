import 'package:flutter/material.dart';
import 'package:final_year_project/screens/admin/user_model.dart';
import 'package:final_year_project/screens/admin/user_service.dart';
import 'package:final_year_project/screens/admin/dependant_model.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _roleController;
  late TextEditingController _statusController;

  late String _selectedDepartment;
  List<Dependant> _dependants = [];

  bool _isLoading = false;
  String _errorMessage = "";

  // List of departments for the dropdown
  final List<String> _departments = [
    "IT",
    "Finance",
    "HR",
    "Marketing",
    "Operations",
    "Sales",
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.secondName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _roleController = TextEditingController(text: widget.user.role);
    _statusController = TextEditingController(text: widget.user.status);
    _selectedDepartment = widget.user.department;
    _dependants = List.from(widget.user.dependants);
    

    // Debugging print statements
    print(
      "User Details Loaded: ${widget.user.firstName} ${widget.user.secondName}",
    );
    print("Initial Department: $_selectedDepartment");
  }

  // Save changes
  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    User updatedUser = User(
      emp_no: widget.user.emp_no,
      firstName: _firstNameController.text,
      secondName: _lastNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      role: _roleController.text,
      status: _statusController.text,
      department: _selectedDepartment,
      image: widget.user.image,
      dependants: _dependants,
    );

    // Debugging print statements
    print(
      "Updating User with: ${updatedUser.firstName} ${updatedUser.secondName}",
    );
    print("Updated Department: ${updatedUser.department}");

    String result = await UserService().updateUser(updatedUser, null);

    setState(() => _isLoading = false);

    if (result.contains("successfully")) {
      Navigator.pop(context, true);
    } else {
      setState(() => _errorMessage = result);
    }

    // Debugging print statements
    print("Update Result: $result");
  }

  // Add a new dependant
  void _addDependant() {
    setState(() {
      _dependants.add(
        Dependant(
          id: DateTime.now().millisecondsSinceEpoch,
          name: "",
          phoneNumber: "",
          relation: "",
        ),
      );
    });

    // Debugging print statement
    print("Added new dependant, total dependants: ${_dependants.length}");
  }

  // Remove a dependant
  void _removeDependant(int index) {
    setState(() {
      _dependants.removeAt(index);
    });

    // Debugging print statement
    print(
      "Removed dependant at index $index, total dependants: ${_dependants.length}",
    );
  }

  // Build a dependant editing row
  Widget _buildDependantRow(int index) {
    Dependant dep = _dependants[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: dep.name,
              decoration: const InputDecoration(labelText: "Dependant Name"),
              onChanged: (value) {
                setState(() {
                  _dependants[index] = dep.copyWith(name: value);
                });
              },
              validator: (value) => value!.isEmpty ? "Enter a name" : null,
            ),
            TextFormField(
              initialValue: dep.phoneNumber,
              decoration: const InputDecoration(labelText: "Phone Number"),
              onChanged: (value) {
                setState(() {
                  _dependants[index] = dep.copyWith(phoneNumber: value);
                });
              },
              validator:
                  (value) => value!.isEmpty ? "Enter phone number" : null,
            ),
            TextFormField(
              initialValue: dep.relation,
              decoration: const InputDecoration(labelText: "Relation"),
              onChanged: (value) {
                setState(() {
                  _dependants[index] = dep.copyWith(relation: value);
                });
              },
              validator: (value) => value!.isEmpty ? "Enter relation" : null,
            ),
            TextButton(
              onPressed: () => _removeDependant(index),
              child: const Text("Remove", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator:
                    (value) => value!.isEmpty ? "Enter first name" : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) => value!.isEmpty ? "Enter last name" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Enter email" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator:
                    (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: "Role"),
                validator: (value) => value!.isEmpty ? "Enter role" : null,
              ),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: "Status"),
                validator: (value) => value!.isEmpty ? "Enter status" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(labelText: "Department"),
                items:
                    _departments.map((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDepartment = newValue!;
                  });
                },
                validator:
                    (value) => value == null ? "Select a department" : null,
              ),
              const SizedBox(height: 20),
              const Text(
                "Dependants",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._dependants
                  .asMap()
                  .entries
                  .map((entry) => _buildDependantRow(entry.key))
                  .toList(),
              TextButton(
                onPressed: _addDependant,
                child: const Text("+ Add Dependant"),
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _updateUser,
                    child: const Text("Update User"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
