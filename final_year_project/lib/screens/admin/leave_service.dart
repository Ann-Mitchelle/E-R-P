import 'dart:convert';
import 'package:http/http.dart' as http;
import 'leave_model.dart';

class ApiService {
  static const String baseUrl =
      "https://sanerylgloann.co.ke/EmployeeManagement";

  /// Fetches leave requests based on status.
  static Future<List<Leave>> fetchLeaves(String status) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_leave.php?status=$status"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('leave_request')) {
          return (data['leave_request'] as List)
              .map((e) => Leave.fromJson(e))
              .toList();
        } else {
          throw Exception("Invalid API response structure");
        }
      } else {
        throw Exception("Failed to load leaves: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching leaves: $e");
    }
  }

  /// Processes leave requests and returns a summary.
  static Map<String, int> processLeaves(List<dynamic> leaves) {
    int pending = 0, approved = 0, rejected = 0, completed = 0, colliding = 0;
    Set<String> checkedLeaves = {};

    for (var leave in leaves) {
      switch (leave["status"]) {
        case "pending":
          pending++;
          break;
        case "approved":
          approved++;
          break;
        case "rejected":
          rejected++;
          break;
        case "completed":
          completed++;
          break;
      }

      // Simple collision check
      String key = "${leave['start_date']}-${leave['end_date']}";
      if (checkedLeaves.contains(key)) {
        colliding++;
      } else {
        checkedLeaves.add(key);
      }
    }

    return {
      "Pending": pending,
      "Approved": approved,
      "Rejected": rejected,
      "Completed": completed,
      "Colliding Leaves": colliding,
    };
  }
}
