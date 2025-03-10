import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:final_year_project/screens/admin/user_model.dart';

class UserService {
  final String baseUrl = "https://sanerylgloann.co.ke/EmployeeManagement";

  // ✅ Register User with Image Upload
  Future<String> addUser(
    User user,
    Uint8List? webImageBytes,
    String? fileName,
    File? mobileImage,
  ) async {
    try {
      var uri = Uri.parse("$baseUrl/create.php");
      var request = http.MultipartRequest("POST", uri);

      user.toMap().forEach((key, value) {
        request.fields[key] = value.toString();
      });

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
      // ✅ Handle Mobile Image Upload (File)
      if (mobileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "profile_image",
            mobileImage.path,
            filename: basename(mobileImage.path),
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
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

  Future<User> getUserByEmpNo(String empNo) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/get_user.php"),
        body: {'emp_no': empNo},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse["status"] == "success") {
          return User.fromJson(jsonResponse["data"]);
        } else {
          throw Exception(jsonResponse["message"]);
        }
      } else {
        throw Exception("Failed to load user");
      }
    } catch (e) {
      throw Exception("Error fetching user: $e");
    }
  }

  // ✅ Update User (With Optional New Image)
  Future<String> updateUser(User user, File? newImage) async {
    try {
      var uri = Uri.parse("$baseUrl/get_user.php");
      var request = http.MultipartRequest("POST", uri);

      // Add user fields
      user.toMap().forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Attach new image if provided
      if (newImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "profile_image",
            newImage.path,
            filename: basename(newImage.path),
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

        try {
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse["message"] ?? "User updated successfully";
      } catch (e) {
        return "Error parsing server response: $responseBody";
      }
    } catch (e) {
      return "Failed to update user: $e";
    }
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
