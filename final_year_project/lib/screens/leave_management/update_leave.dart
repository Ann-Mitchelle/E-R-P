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

  Future<void> _getLeaveDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://sanerylgloann.co.ke/EmployeeManagement/display_specific_leave.php?id=${widget.leaveId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          setState(() {
            status = data['data']['status'].toString();
            department = data['data']['department'];
            fullname = data['data']['fullname'];
            leaveType = data['data']['leave_type'];
            startDate = data['data']['start_date'];
            endDate = data['data']['end_date'];
            duration = data['data']['duration'].toString();
            notes = data['data']['notes'];
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load leave details')),
          );
          setState(() {
            isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load leave details')));
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateLeaveStatus(String newStatus) async {
    try {
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

      final data = json.decode(response.body);

      if (data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave request updated successfully')),
        );
        _getLeaveDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update leave request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Request Detail')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateLeaveStatus('Approved'),
                            child: Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateLeaveStatus('Rejected'),
                            child: Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
