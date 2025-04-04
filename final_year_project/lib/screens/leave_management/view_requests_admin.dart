import 'package:final_year_project/screens/leave_management/update_leave.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import the detail page

class AdminLeaveRequestsPage extends StatefulWidget {
  @override
  _AdminLeaveRequestsPageState createState() => _AdminLeaveRequestsPageState();
}

class _AdminLeaveRequestsPageState extends State<AdminLeaveRequestsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _leaveRequests = [];
  List<dynamic> _filteredRequests = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchQuery = "";
  String _status = ""; // No default status filter
  String _department = ""; // No default department filter

  // Fetch leave requests with dynamic filters
  Future<void> _fetchLeaveRequests() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // Construct the URL dynamically without pagination params
    final url = Uri.parse(
      'https://sanerylgloann.co.ke/EmployeeManagement/display_leave_admin.php?'
      'status=$_status&department=$_department',
    );

    print('Fetching URL: $url'); // Debug: Log the URL to check if it's correct

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == false) {
          throw Exception('Error from API: ${data['message']}');
        }

        final List<dynamic> fetchedRequests = List.from(data['data']);
        setState(() {
          _leaveRequests.addAll(fetchedRequests);
          _filteredRequests = List.from(_leaveRequests);
          _isLoading = false;
          _hasMore =
              fetchedRequests.isNotEmpty; // Check if more data is available
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $error'); // Debug: Log the error
    }
  }

  // Search logic for name or department
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredRequests =
          _leaveRequests.where((request) {
            final fullName = request['fullname'].toLowerCase();
            final department = request['department'].toLowerCase();
            return fullName.contains(_searchQuery) ||
                department.contains(_searchQuery);
          }).toList();
    });
  }

  // Listen for scroll to trigger pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchLeaveRequests();
    }
  }

  // Color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Requests'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or Department',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Department and Status Filters
            Row(
              children: [
                // Filter by department
                DropdownButton<String>(
                  value: _department.isEmpty ? null : _department,
                  hint: Text("Select Department"),
                  items:
                      [
                        'HR',
                        'IT',
                        'Finance',
                        'Admin',
                      ] // List your departments here
                      .map((department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _department = value!;
                      _leaveRequests.clear();
                      _filteredRequests.clear();
                      _fetchLeaveRequests();
                    });
                  },
                ),
                SizedBox(width: 10),
                // Filter by status
                DropdownButton<String>(
                  value: _status.isEmpty ? null : _status,
                  hint: Text("Select Status"),
                  items:
                      ['Pending', 'Approved', 'Rejected'].map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                      _leaveRequests.clear();
                      _filteredRequests.clear();
                      _fetchLeaveRequests();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            // Leave Requests List
            Expanded(
              child:
                  _filteredRequests.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            _filteredRequests.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredRequests.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final req = _filteredRequests[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => LeaveRequestDetailPage(
                                        leaveId: req['id'],
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                              child: ListTile(
                                leading: Icon(
                                  Icons.person,
                                  color: Colors.blueAccent,
                                ),
                                title: Text(req['fullname']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Dept: ${req['department']}"),
                                    Text("Type: ${req['leave_type']}"),
                                    Text(
                                      "Date: ${req['start_date']} - ${req['end_date']}",
                                    ),
                                  ],
                                ),
                                trailing: Chip(
                                  label: Text(
                                    req['status'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getStatusColor(
                                    req['status'],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
