import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyApplicationsPage extends StatefulWidget {
  @override
  _MyApplicationsPageState createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  List<dynamic> applications = [];
  String? empNo; // ✅ Store emp_no from SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadEmployeeNumber();
  }

  Future<void> _loadEmployeeNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empNo = prefs.getString("emp_no"); // ✅ Retrieve emp_no
    });

    if (empNo != null) {
      _fetchApplications();
    }
  }

  Future<void> _fetchApplications() async {
    if (empNo == null) return; // ✅ Ensure emp_no is available

    try {
      final url =
          "https://sanerylgloann.co.ke/EmployeeManagement/view_job_applications.php?emp_no=$empNo";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["status"] == "success") {
          setState(() {
            applications = jsonData["applications"];
          });
        } else {
          throw Exception("Error fetching applications");
        }
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showApplicationDetails(
    BuildContext context,
    Map<String, dynamic> application,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text("Application Details", textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(
                  "Job No:",
                  application['jobno']?.toString() ?? "N/A",
                ),
                _detailRow(
                  "Full Name:",
                  application['full_name']?.toString() ?? "N/A",
                ),
                _detailRow(
                  "Applied on:",
                  application['submission_date']?.toString() ?? "N/A",
                ),
                SizedBox(height: 10),
                Text(
                  "Application Text:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  application['application_text']?.toString() ??
                      "No text provided",
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                Text(
                  "Attachments:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                _attachmentButton(
                  application['resume_path']?.toString(),
                  "Resume",
                ),
                _attachmentButton(
                  application['supporting_document_path']?.toString(),
                  "Supporting Document",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close", style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Expanded(
            child: Text(value ?? "N/A", overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _attachmentButton(String? path, String label) {
    if (path == null || path.isEmpty) return SizedBox();
    return TextButton.icon(
      icon: Icon(Icons.file_present, color: Colors.blue),
      label: Text(label, style: TextStyle(color: Colors.blue)),
      onPressed: () {
        // Open file logic (Optional: Implement this to allow file downloads)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Applications")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child:
            empNo == null
                ? Center(child: Text("Loading employee details..."))
                : applications.isEmpty
                ? Center(child: Text("No applications found"))
                : ListView.builder(
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    var application = applications[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.work, color: Colors.blue),
                        title: Text(
                          "Job No: ${application['jobno'].toString()}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Applied on: ${application['submission_date']?.toString() ?? "N/A"}",
                            ),
                            SizedBox(height: 5),
                            Text(
                              application['application_text']?.toString() ??
                                  "No text provided",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue,
                        ),
                        onTap:
                            () => _showApplicationDetails(context, application),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
