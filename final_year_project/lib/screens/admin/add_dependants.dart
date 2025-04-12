import 'package:final_year_project/screens/admin/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddDependantScreen extends StatefulWidget {
  final User user; // Employee number passed from previous screen

  AddDependantScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AddDependantScreenState createState() => _AddDependantScreenState();
}

class _AddDependantScreenState extends State<AddDependantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitDependant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final dependantData = {
      'emp_no': widget.user.emp_no,
      // Debugging print statement
      'name': _nameController.text.trim(),
      'phoneNumber':
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      'relation': _relationController.text.trim(),
    };
    print('Employee Number: ${dependantData}');

    final response = await http.post(
      Uri.parse(
        'https://sanerylgloann.co.ke/EmployeeManagement/add_dependant.php',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dependantData),
    );

    final result = jsonDecode(response.body);
    print(result); // Debugging print statement

    setState(() {
      _isSubmitting = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Dependant added successfully')));
      Navigator.pop(context); // Go back after success
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${result['message']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Dependant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Dependant Name'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter name'
                            : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (optional)',
                ),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _relationController,
                decoration: InputDecoration(labelText: 'Relation'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter relation'
                            : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDependant,
                child: Text(_isSubmitting ? 'Submitting...' : 'Add Dependant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
