import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  ResetPasswordScreen({required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true; // 👁️ toggle visibility

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final code = _codeController.text.trim();
      final newPass = _newPassController.text.trim();

      final success = await resetPassword(widget.email, code, newPass);

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Password reset successfully!')));
        Navigator.pushReplacementNamed(context, '/');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid code or expired')));
      }
    }
  }

  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://sanerylgloann.co.ke/EmployeeManagement/verify_reset.php',
        ),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'code': code, 'new_password': newPassword},
      );

      final data = json.decode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Enter the code sent to ${widget.email}"),
              SizedBox(height: 10),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: "Code"),
                validator: (val) => val!.isEmpty ? "Enter code" : null,
              ),
              TextFormField(
                controller: _newPassController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "New Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator:
                    (val) => val!.length < 6 ? "Password too short" : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    child: Text("Reset Password"),
                    onPressed: _resetPassword,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
