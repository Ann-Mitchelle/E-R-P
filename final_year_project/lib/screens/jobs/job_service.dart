import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiJobsService {
  static const String baseUrl =
      "https://sanerylgloann.co.ke/EmployeeManagement";

  // Fetch jobs from API
  static Future<List<Map<String, dynamic>>> fetchJobs() async {
    final response = await http.get(Uri.parse("$baseUrl/get_jobs.php"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"]) {
        return List<Map<String, dynamic>>.from(data["jobs"]);
      }
    }
    throw Exception("Failed to load jobs");
  }

  // Delete job API
  static Future<bool> deleteJob(int jobNo) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete_jobs.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"jobno": jobNo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"];
      } else {
        return false;
      }
    } catch (e) {
      print("Error deleting job: $e");
      return false;
    }
  }

  // Edit job API
  static Future<bool> editJob({
    required int jobNo,
    required String title,
    required String department,
    required String location,
    required String employmentType,
    required String description,
    required String qualifications,
    required String deadline,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/edit_job.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jobno": jobNo,
          "job_title": title,
          "department": department,
          "location": location,
          "employment_type": employmentType,
          "description": description,
          "qualifications": qualifications,
          "deadline": deadline,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"];
      } else {
        return false;
      }
    } catch (e) {
      print("Error editing job: $e");
      return false;
    }
  }
}
