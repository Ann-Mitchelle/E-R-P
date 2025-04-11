import 'dart:convert';
import 'package:http/http.dart' as http;
import 'training_model.dart';

class ApiTrainingService {
  static const String baseUrl =
      "https://sanerylgloann.co.ke/EmployeeManagement";

  // Fetch training details
  static Future<Training?> fetchTraining(String trainingId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_training_details.php?id=$trainingId"),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] && data.containsKey('training')) {
        return Training.fromJson(data['training']);
      }
    }
    return null;
  }

  // Edit Training
  // static Future<bool> editTraining({
  //   required String trainingId,
  //   required String title,
  //   required String description,
  //   required String startDate,
  //   required String endDate,
  //   required String location,
  //   required String duration,
  //   required List<String> participants,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("$baseUrl/update_training.php"),
  //       headers: {"Content-Type": "application/x-www-form-urlencoded"},
  //       body: {
  //         "training_id": trainingId,
  //         "title": title,
  //         "description": description,
  //         "start_date": startDate,
  //         "end_date": endDate,
  //         "location": location,
  //         "duration": duration,
  //         "participants": participants,
  //       },
  //     );

  //     // Debugging
  //     print("Response Status Code: ${response.statusCode}");
  //     print("Response Body: ${response.body}");
  //     print(response.body);

  //     final Map<String, dynamic> responseData = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       if (responseData.containsKey("success") &&
  //           responseData["success"] == true) {
  //         return true;
  //       } else {
  //         print("API Error: ${responseData['error']}");
  //         return false;
  //       }
  //     } else {
  //       print("Server Error: ${response.statusCode}");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Network Error: $e");
  //     return false;
  //   }
  //} }
  static Future<bool> updateTraining(Training training) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update_training.php?id=${training.trainingId}'),
        body: {
          'training_id': training.trainingId, // 🟢 Ensure correct training ID
          'title': training.title,
          'description': training.description,
          'start_date': training.startDate,
          'end_date': training.endDate,
          'location': training.location,
          'duration': training.duration,
          'participants': jsonEncode(training.participants),
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success']) {
          return true;
        } else {
          print(responseData['error']);
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print("Error updating training: $e");
      return false;
    }
  }

  // Delete Training
  static Future<bool> deleteTraining(String trainingId) async {
    final response = await http.post(
      Uri.parse(
        "https://sanerylgloann.co.ke/EmployeeManagement/delete_training.php",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": trainingId}),
    );

    print("API Response Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success']; // Ensure backend returns success: true
    }
    return false;
  }
}
