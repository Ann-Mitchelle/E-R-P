import 'dart:io';
import 'dart:typed_data';
import 'package:final_year_project/screens/admin/dependant_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:final_year_project/screens/admin/user_model.dart';

class UserService {
  final String baseUrl = "https://sanerylgloann.co.ke/EmployeeManagement";

  // ✅ Register User with Image & Dependants
  Future<String> addUser(
    User user,
    Uint8List? webImageBytes,
    String? fileName,
    File? mobileImage,
    List<Dependant> dependants, // 🟢 Add dependants parameter
  ) async {
    try {
      var uri = Uri.parse("$baseUrl/create.php");
      var request = http.MultipartRequest("POST", uri);

      // ✅ Convert User object to Map and add to request fields
      user.toMap().forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // ✅ Convert dependants list to JSON string
      String dependantsJson = jsonEncode(
        dependants.map((d) => d.toMap()).toList(),
      );
      request.fields["dependants"] =
          dependantsJson; // 🟢 Send dependants as JSON

      // ✅ Handle web image upload
      if (webImageBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "profile_image",
            webImageBytes,
            filename: fileName,
          ),
        );
      }

      // ✅ Handle mobile image upload
      if (mobileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "profile_image",
            mobileImage.path,
            filename: basename(mobileImage.path),
          ),
        );
      }

      // 🟢 Debugging: Print JSON before sending
      print("Sending Dependants JSON: $dependantsJson");

      // ✅ Send the request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      // 🟢 Debugging: Print server response
      print("Server Response: $responseBody");

      try {
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse["message"] ?? "User registered successfully";
      } catch (e) {
        return "Error parsing server response: $responseBody";
      }
    } catch (e) {
      return "Failed to register user: $e";
    }
  }

  // ✅ Fetch User by Employee Number
  Future<User> getUserByEmpNo(String empNo) async {
    try {
      final url =
          "https://sanerylgloann.co.ke/EmployeeManagement/get_user.php?emp_no=$empNo";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );

      print("Fetching user from: $url");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey("error")) {
          throw Exception("Server Error: ${jsonResponse["error"]}");
        }

        return User.fromJson(jsonResponse);
      } else {
        throw Exception(
          "Server responded with status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching user: $e");
    }
  }

  Future<String> updateUser(User user, String? password) async {
    Map<String, dynamic> data = {
      "emp_no": user.emp_no,
      "firstName": user.firstName,
      "secondName": user.secondName,
      "email": user.email,
      "phoneNumber": user.phoneNumber,
      "role": user.role,
      "status": user.status,
      "department": user.department,
      "image": user.image,
      "dependants": user.dependants.map((d) => d.toMap()).toList(),
    };

    if (password != null && password.isNotEmpty) {
      data["password"] = password; // ✅ Only add password if provided
    }

    // Call API or Database update here
    return "User updated successfully"; // Example response
  }

  // ✅ Fetch All Users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/viewusers.php"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }
}
