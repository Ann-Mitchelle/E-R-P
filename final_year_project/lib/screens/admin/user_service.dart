import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:final_year_project/screens/admin/user_model.dart';
import 'package:final_year_project/screens/admin/dependant_model.dart';

class UserService {
  final String baseUrl = "https://sanerylgloann.co.ke/EmployeeManagement";

  // ✅ Register User with Image & Dependants
  Future<String> addUser(
    User user,
    Uint8List? webImageBytes,
    String? fileName,
    File? mobileImage,
    List<Dependant> dependants,
  ) async {
    try {
      var uri = Uri.parse("$baseUrl/create.php");
      var request = http.MultipartRequest("POST", uri);

      // Add user fields
      user.toMap().forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Convert dependants to JSON and add to fields
      String dependantsJson = jsonEncode(
        dependants.map((d) => d.toMap()).toList(),
      );
      request.fields["dependants"] = dependantsJson;

      // Upload web image
      if (webImageBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "profile_image",
            webImageBytes,
            filename: fileName,
          ),
        );
      }

      // Upload mobile image
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

  // ✅ Fetch user by emp_no
  Future<User> getUserByEmpNo(String empNo) async {
    try {
      final url = "$baseUrl/get_user.php?emp_no=$empNo";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );

      print("Fetching user from: $url");
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

  // ✅ Fetch leave balances
  Future<Map<String, int?>> getLeaveBalances(String empNo) async {
    try {
      final url = "$baseUrl/get_leave_balances.php?emp_no=$empNo";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );

      print("Leave balances response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var leaveData = jsonResponse["leave_balances"][0];

        return {
          "Annual": leaveData["Annual"],
          "Sick": leaveData["Sick"],
          "Maternity": leaveData["Maternity"],
          "paternity": leaveData["paternity"], // Case-sensitive fix
        };
      } else {
        throw Exception("Status code error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching leave balances: $e");
    }
  }

  // ✅ Update user

  Future<String> updateUser(User user, String? password) async {
    // Preparing the data to send
    Map<String, dynamic> data = {
      "emp_no": user.emp_no,
      "firstname": user.firstName,
      "secondname": user.secondName,
      "email": user.email,
      "phonenumber": user.phoneNumber,
      "role": user.role,
      "status": user.status,
      "department": user.department,
      "image": user.image,
      "dependants": jsonEncode(user.dependants.map((d) => d.toMap()).toList()),
    };

    // Add password if it's not null or empty
    if (password != null && password.isNotEmpty) {
      data["password"] = password;
    }

    try {
      // Sending the HTTP POST request
      final response = await http.post(
        Uri.parse(
          "https://sanerylgloann.co.ke/EmployeeManagement/update_user.php",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      // Check if the response status is OK (200)
      if (response.statusCode == 200) {
        // Try parsing the response body as JSON
        try {
          final responseBody = jsonDecode(response.body);
          // Check if the response contains the 'message' field
          if (responseBody.containsKey('message')) {
            return responseBody['message'];
          } else {
            return "Error: Unexpected response format.";
          }
        } catch (e) {
          // Handle the case where the response is not valid JSON
          print("Error parsing response: $e");
          return "Error: Response is not valid JSON.";
        }
      } else {
        // Handle the case where the server returns a non-OK status code
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      // Handle network errors or any exceptions that occur during the request
      print("Error updating user: $e");
      return "Error: Unable to update user. Please try again later.";
    }
  }

  // ✅ Fetch all users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/viewusers.php"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(
          "Failed to load users. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }
}
