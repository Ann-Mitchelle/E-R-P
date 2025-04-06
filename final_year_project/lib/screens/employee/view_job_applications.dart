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
  List<dynamic> filteredApplications = [];
  String? empNo;
  String selectedStatus = "All"; // Store selected status for filtering

  @override
  void initState() {
    super.initState();
    _loadEmployeeNumber();
  }

  Future<void> _loadEmployeeNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empNo = prefs.getString("emp_no");
    });

    if (empNo != null) {
      _fetchApplications();
    }
  }

  Future<void> _fetchApplications() async {
    if (empNo == null) return;

    try {
      final url =
          "https://sanerylgloann.co.ke/EmployeeManagement/view_job_applications.php?emp_no=$empNo";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["status"] == "success") {
          setState(() {
            applications = jsonData["applications"];
            _filterApplications();
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

  void _filterApplications() {
    setState(() {
      if (selectedStatus == "All") {
        filteredApplications = applications;
      } else {
        filteredApplications =
            applications
                .where(
                  (app) =>
                      app['status'].toString().toLowerCase() ==
                      selectedStatus.toLowerCase(),
                )
                .toList();
      }
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[800]!;
      case 'accepted':
        return Colors.green[800]!;
      case 'rejected':
        return Colors.red[800]!;
      default:
        return Colors.black;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'pending':
      default:
        return Icons.hourglass_empty;
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
        // Optional: Implement file download logic here
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Applications"),
        actions: [
          DropdownButton<String>(
            value: selectedStatus,
            icon: Icon(Icons.filter_list, color: Colors.orange),
            dropdownColor: Colors.blue,
            items:
                <String>[
                  'All',
                  'Pending',
                  'Approved',
                  'Rejected',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedStatus = newValue!;
                _filterApplications(); // Filter applications based on the selected status
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child:
            empNo == null
                ? Center(child: Text("Loading employee details..."))
                : filteredApplications.isEmpty
                ? Center(child: Text("No applications found"))
                : ListView.builder(
                  itemCount: filteredApplications.length,
                  itemBuilder: (context, index) {
                    var application = filteredApplications[index];
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
                          getStatusIcon(application['status']),
                          color: getStatusColor(application['status']),
                        ),
                        tileColor: getStatusColor(
                          application['status'],
                        ).withOpacity(0.1),
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
