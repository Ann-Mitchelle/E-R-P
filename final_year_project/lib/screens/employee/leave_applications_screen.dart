import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveApplicationsScreen extends StatefulWidget {
  @override
  _LeaveApplicationsScreenState createState() =>
      _LeaveApplicationsScreenState();
}

class _LeaveApplicationsScreenState extends State<LeaveApplicationsScreen> {
  late Future<List<Map<String, dynamic>>> futureApplications;
  String selectedStatus = 'pending'; // Default status is 'pending'

  // Variable to hold the emp_no from SharedPreferences
  String empNo = '';

  @override
  void initState() {
    super.initState();
    // Fetch the employee number (emp_no) dynamically from SharedPreferences
    _loadEmpNo();
  }

  // Function to load the emp_no from SharedPreferences
  Future<void> _loadEmpNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empNo = prefs.getString("emp_no") ?? ''; // Default to empty if not found
    });

    // After loading emp_no, fetch the leave applications
    if (empNo.isNotEmpty) {
      futureApplications = fetchLeaveApplications(empNo, selectedStatus);
    }
  }

  // Function to fetch leave applications based on emp_no and status
  Future<List<Map<String, dynamic>>> fetchLeaveApplications(
    String empNo,
    String status,
  ) async {
    final String url =
        'https://sanerylgloann.co.ke/EmployeeManagement/display_leave.php?emp_no=$empNo&status=$status';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Failed to load leave applications');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }

  // Function to update status and fetch the leave applications based on the selected status
  void updateStatus(String status) {
    setState(() {
      selectedStatus = status;
      futureApplications = fetchLeaveApplications(empNo, selectedStatus);
    });
  }

  // Method to get the status color based on status
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

  // Method to get the status icon based on status
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Applications"),
        backgroundColor: Colors.blue, // Blue theme for the AppBar
      ),
      body: Column(
        children: [
          // Row with buttons for status
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => updateStatus('pending'),
                  child: Text('Pending'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Orange color for Pending
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => updateStatus('approved'),
                  child: Text('Approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green color for Approved
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => updateStatus('rejected'),
                  child: Text('Rejected'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red color for Rejected
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureApplications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No leave applications found.'));
                } else {
                  // Data available, display the leave applications
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final application = snapshot.data![index];
                      return ListTile(
                        title: Text(
                          application['leave_type'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${application['start_date']} to ${application['end_date']} - ${application['duration']} days',
                        ),
                        trailing: Icon(
                          getStatusIcon(application['status']),
                          color: getStatusColor(application['status']),
                        ),
                        tileColor: getStatusColor(
                          application['status'],
                        ).withOpacity(0.1),
                        onTap: () {
                          // Show the details in a popup
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(application['leave_type']),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start Date: ${application['start_date']}',
                                      ),
                                      Text(
                                        'End Date: ${application['end_date']}',
                                      ),
                                      Text(
                                        'Duration: ${application['duration']} days',
                                      ),
                                      Text('Notes: ${application['notes']}'),
                                      if (application['document_path'] != null)
                                        Text(
                                          'Document: ${application['document_path']}',
                                        ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
