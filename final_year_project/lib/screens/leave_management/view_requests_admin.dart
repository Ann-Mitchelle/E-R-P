import 'package:final_year_project/screens/leave_management/update_leave.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';

class AdminLeaveRequestsPage extends StatefulWidget {
  @override
  _AdminLeaveRequestsPageState createState() => _AdminLeaveRequestsPageState();
}

class _AdminLeaveRequestsPageState extends State<AdminLeaveRequestsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _leaveRequests = [];
  List<dynamic> _filteredRequests = [];
  bool _isLoading = false;
  String _searchQuery = "";
  String _status = "";
  String _department = "";

  // Fetch leave requests
  Future<void> _fetchLeaveRequests() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://sanerylgloann.co.ke/EmployeeManagement/display_leave_admin.php?'
      'status=$_status&department=$_department',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == false) {
          throw Exception('Error from API: ${data['message']}');
        }

        final List<dynamic> fetchedRequests = List.from(data['data']);
        setState(() {
          _leaveRequests = fetchedRequests;
          _filteredRequests = List.from(_leaveRequests);
          _isLoading = false;
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
      print('Error: $error');
    }
  }

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

  Future<void> _generatePdfReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Leave Requests Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (_status.isNotEmpty || _department.isNotEmpty)
                pw.Paragraph(
                  text:
                      'Filters - Status: ${_status.isEmpty ? "All" : _status}, Department: ${_department.isEmpty ? "All" : _department}',
                ),
              pw.Table.fromTextArray(
                headers: ['Name', 'Department', 'Type', 'From', 'To', 'Status'],
                data:
                    _filteredRequests.map((leave) {
                      return [
                        leave['fullname'],
                        leave['department'],
                        leave['leave_type'],
                        leave['start_date'],
                        leave['end_date'],
                        leave['status'],
                      ];
                    }).toList(),
              ),
            ],
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/leave_report.pdf");
      await file.writeAsBytes(await pdf.save());

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print("Error generating PDF: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or Department',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Filters
            Row(
              children: [
                DropdownButton<String>(
                  value: _department.isEmpty ? null : _department,
                  hint: Text("Select Department"),
                  items:
                      ['HR', 'IT', 'Finance', 'Admin'].map((department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _department = value!;
                      _fetchLeaveRequests();
                    });
                  },
                ),
                SizedBox(width: 10),
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
                      _fetchLeaveRequests();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            // PDF Button
            ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Generate Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => _generatePdfReport(),
            ),
            SizedBox(height: 10),

            // Leave List
            Expanded(
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredRequests.isEmpty
                      ? Center(child: Text('No leave requests found.'))
                      : ListView.builder(
                        itemCount: _filteredRequests.length,
                        itemBuilder: (context, index) {
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
