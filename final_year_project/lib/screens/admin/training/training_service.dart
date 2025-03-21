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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] && data.containsKey('training')) {
        return Training.fromJson(data['training']);
      }
    }
    return null;
  }

  // Edit Training
  static Future<bool> editTraining({
    required String trainingId,
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_training.php"),
      body: {
        "training_id": trainingId,
        "title": title,
        "description": description,
        "start_date": startDate,
        "end_date": endDate,
        "location": location,
      },
    );

    return response.statusCode == 200 && jsonDecode(response.body)['success'];
  }

  // Delete Training
  static Future<bool> deleteTraining(String trainingId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_training.php"),
      body: {"training_id": trainingId},
    );

    return response.statusCode == 200 && jsonDecode(response.body)['success'];
  }
}
