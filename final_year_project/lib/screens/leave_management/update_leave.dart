import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaveRequestDetailPage extends StatefulWidget {
  final int leaveId;

  LeaveRequestDetailPage({required this.leaveId});

  @override
  _LeaveRequestDetailPageState createState() => _LeaveRequestDetailPageState();
}

class _LeaveRequestDetailPageState extends State<LeaveRequestDetailPage> {
  String status = '';
  String department = '';
  String fullname = '';
  String leaveType = '';
  String startDate = '';
  String endDate = '';
  String duration = '';
  String notes = '';
  bool isLoading = true;
  final TextEditingController remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLeaveDetails();
  }

  // Fetch leave request details from the backend
  Future<void> _getLeaveDetails() async {
    try {
      print(
        'Fetching leave details for leaveId: ${widget.leaveId.toString()}',
      ); // Debug: Print leaveId

      // Fetch the details using the leaveId
      final response = await http.get(
        Uri.parse(
          'https://sanerylgloann.co.ke/EmployeeManagement/display_specific_leave.php?id=${widget.leaveId.toString()}',
        ),
      );

      print(
        'Response Status: ${response.statusCode}',
      ); // Debug: Print response status code

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response Body: $data'); // Debug: Print response body

        if (data['success']) {
          setState(() {
            status =
                data['data']['status'].toString(); // Convert status to string
            department = data['data']['department'];
            fullname = data['data']['fullname'];
            leaveType = data['data']['leave_type'];
            startDate = data['data']['start_date'];
            endDate = data['data']['end_date'];
            duration = data['data']['duration'];
            notes = data['data']['notes'];
            isLoading =
                false; // Set loading state to false after data is loaded
            print('Leave Details Loaded: $fullname, $department, $leaveType');
          });
        } else {
          // Handle the error response
          print('Error: ${data['message']}'); // Debug: Print error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load leave details')),
          );
          setState(() {
            isLoading = false; // Set loading state to false if there's an error
          });
        }
      } else {
        // Handle non-200 status codes
        print(
          'Failed to load data, status code: ${response.statusCode}',
        ); // Debug: Print failed status code
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load leave details')));
        setState(() {
          isLoading = false; // Set loading state to false if the request failed
        });
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e'); // Debug: Print the exception
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        isLoading = false; // Set loading state to false if there's an exception
      });
    }
  }

  // Approve or Reject the leave request
  Future<void> _updateLeaveStatus(String newStatus) async {
    try {
      print(
        'Updating leave request status to: $newStatus',
      ); // Debug: Print the new status

      final response = await http.post(
        Uri.parse(
          'https://sanerylgloann.co.ke/EmployeeManagement/update_leave.php',
        ),
        body: {
          'id': widget.leaveId.toString(),
          'status': newStatus,
          'remarks': remarksController.text,
        },
      );

      print(
        'Response Status: ${response.statusCode}',
      ); // Debug: Print response status code
      final data = json.decode(response.body);
      print('Response Body: $data'); // Debug: Print response body

      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave request updated successfully')),
        );
        // Optionally, reload the leave details after updating
        _getLeaveDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update leave request')),
        );
      }
    } catch (e) {
      print('Error: $e'); // Debug: Print the exception
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Request Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(),
                ) // Show loading indicator
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Name: $fullname',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Department: $department',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Leave Type: $leaveType',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start Date: $startDate',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('End Date: $endDate', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      'Duration: $duration days',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('Status: $status', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Notes: $notes', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    TextField(
                      controller: remarksController,
                      decoration: InputDecoration(
                        labelText: 'Add Remarks',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _updateLeaveStatus('Approved'),
                          child: Text('Approve'),
                        ),
                        ElevatedButton(
                          onPressed: () => _updateLeaveStatus('Rejected'),
                          child: Text('Reject'),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
