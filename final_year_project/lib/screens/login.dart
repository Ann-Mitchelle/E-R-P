import 'dart:convert';
import 'package:final_year_project/screens/widgets/custom_button.dart';
import 'package:final_year_project/screens/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Please enter email and password");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var url = Uri.parse(
      "https://sanerylgloann.co.ke/EmployeeManagement/login.php",
    );
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data["status"] == "success") {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString("emp_no", data["user"]["emp_no"]);
        await prefs.setString("email", data["user"]["email"]);
        await prefs.setString("firstname", data["user"]["firstname"]);
        await prefs.setString("secondname", data["user"]["secondname"]);
        await prefs.setString("phonenumber", data["user"]["phonenumber"]);
        await prefs.setString("department", data["user"]["department"]);
        await prefs.setString("role", data["user"]["role"]);
        await prefs.setString("profile_picture", data["user"]["image"]);

        if (_rememberMe) {
          await prefs.setBool("rememberMe", true);
        } else {
          await prefs.remove("rememberMe");
        }

        _showSnackbar("Login Successful");

        if (data["user"]["role"] == "admin") {
          Navigator.pushReplacementNamed(context, "/admin_dashboard");
        } else {
          Navigator.pushReplacementNamed(context, '/employee_dashboard');
        }
      } else {
        _showSnackbar(data["message"]);
      }
    } else {
      _showSnackbar("Server error, please try again");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Welcome to StaffEase"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Logo
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ic_launcher.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Welcome Text
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Please login to your account",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Email
                CustomTextField(
                  controller: _emailController,
                  hintText: "Enter your email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Enter your password",
                  icon: Icons.lock,
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                        const Text(
                          "Remember Me",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        _navigateTo(context, "/forgot_password");
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(text: "Login", onPressed: _login),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
