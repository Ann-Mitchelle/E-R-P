import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JobApplicationsPage extends StatefulWidget {
  @override
  _JobApplicationsPageState createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  List<dynamic> applications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    final response = await http.get(
      Uri.parse(
        'https://sanerylgloann.co.ke/EmployeeManagement/view_job_applications_admin.php',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          applications = data['data'];
          isLoading = false;
        });
      }
    }
  }

  void updateStatus(int id, String status, String remarks) async {
    final response = await http.post(
      Uri.parse(
        'https://sanerylgloann.co.ke/EmployeeManagement/update_job_applications.php',
      ),
      body: {
        'id': id.toString(), // Ensure it's a string in the HTTP request
        'status': status,
        'remarks': remarks,
      },
    );

    final data = json.decode(response.body);
    if (data['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated successfully!')));
      fetchApplications(); // Reload list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Error updating')),
      );
    }
  }

  void showActionDialog(Map<String, dynamic> application) {
    TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Update Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Job Title: ${application['job_title']}'),
                SizedBox(height: 8),
                Text('Full Name: ${application['full_name']}'),
                SizedBox(height: 8),
                Text('Application Letter: ${application['application_text']}'),
                SizedBox(height: 8),
                Text('Submission Date: ${application['submission_date']}'),
                SizedBox(height: 8),
                Text('Resume Path: ${application['resume_path']}'),
                SizedBox(height: 8),
                Text('Status: ${application['status'] ?? 'Pending'}'),
                SizedBox(height: 8),
                TextField(
                  controller: remarksController,
                  decoration: InputDecoration(labelText: 'Remarks'),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Reject'),
                onPressed: () {
                  updateStatus(
                    int.parse(application['id'].toString()), // Fixed here
                    'Rejected',
                    remarksController.text.trim(),
                  );
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text('Approve'),
                onPressed: () {
                  updateStatus(
                    int.parse(application['id'].toString()), // Fixed here
                    'Approved',
                    remarksController.text.trim(),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Applications')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return Card(
                    child: ListTile(
                      title: Text(app['full_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Job No: ${app['jobno']}'),
                          Text('Status: ${app['status'] ?? 'Pending'}'),
                          Text('Submitted: ${app['submission_date']}'),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => showActionDialog(app),
                    ),
                  );
                },
              ),
    );
  }
}
