import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _sendResetCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final email = _emailController.text.trim();

      final success = await sendResetCodeToEmail(email);

      setState(() => _isLoading = false);

      if (success) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text("Code Sent"),
                content: Text("Check your email for the reset code."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pushNamed(
                        context,
                        '/reset_password',
                        arguments: email,
                      );
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not send reset code. Please check your email or try again.',
            ),
          ),
        );
      }
    }
  }

  Future<bool> sendResetCodeToEmail(String email) async {
    try {
      print("Email being sent: $email"); // Debugging line

      final response = await http.post(
        Uri.parse(
          'https://sanerylgloann.co.ke/EmployeeManagement/request_reset.php',
        ),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email},
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return true;
        } else {
          // Show backend error message in UI
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Unknown error occurred.'),
            ),
          );
        }
      }
      return false;
    } catch (e) {
      print("Exception caught: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Please try again.')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Enter your email to receive a reset code."),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (val) =>
                        val == null || !val.contains("@")
                            ? "Enter a valid email"
                            : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text("Send Reset Code"),
                      onPressed: _isLoading ? null : _sendResetCode,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
