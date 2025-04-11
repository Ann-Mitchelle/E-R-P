import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
//import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
//import 'package:google_fonts/google_fonts.dart' as gf;
import 'package:printing/printing.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:share_plus/share_plus.dart';
import 'update_leave.dart';

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

  Future<void> _fetchLeaveRequests() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://sanerylgloann.co.ke/EmployeeManagement/display_leave_admin.php?'
      'status=$_status&department=$_department',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _leaveRequests = data['data'];
          _filteredRequests = _leaveRequests;
        });
      }
    } catch (error) {
      print('Error fetching leave requests: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredRequests =
          _leaveRequests.where((request) {
            final name = request['fullname'].toLowerCase();
            final dept = request['department'].toLowerCase();
            return name.contains(_searchQuery) || dept.contains(_searchQuery);
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

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoExtraBold();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            children: [
              pw.Text(
                'Leave Requests Report',
                style: pw.TextStyle(font: boldFont, fontSize: 24),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                  'Name',
                  'Department',
                  'Leave Type',
                  'Start',
                  'End',
                  'Status',
                ],
                data:
                    _filteredRequests.map((req) {
                      return [
                        req['fullname'],
                        req['department'],
                        req['leave_type'],
                        req['start_date'],
                        req['end_date'],
                        req['status'],
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(font: boldFont),
                cellStyle: pw.TextStyle(font: font),
                border: pw.TableBorder.all(),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _previewPdf() async {
    final pdfData = await _generatePdf();
    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }

  void _sharePdf() async {
    final pdfData = await _generatePdf();

    if (kIsWeb) {
      // Web doesn't support Share
      await Printing.sharePdf(bytes: pdfData, filename: 'leave_report.pdf');
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/leave_report.pdf');
      await file.writeAsBytes(pdfData);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Here is the leave report PDF.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Requests'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _previewPdf,
            tooltip: 'Preview PDF',
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _sharePdf,
            tooltip: 'Share PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or Department',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                DropdownButton<String>(
                  value: _department.isEmpty ? null : _department,
                  hint: Text("Select Department"),
                  items:
                      ['HR', 'IT', 'Finance', 'Admin']
                          .map(
                            (dept) => DropdownMenuItem(
                              child: Text(dept),
                              value: dept,
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() {
                      _department = val!;
                      _fetchLeaveRequests();
                    });
                  },
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _status.isEmpty ? null : _status,
                  hint: Text("Select Status"),
                  items:
                      ['Pending', 'Approved', 'Rejected']
                          .map(
                            (stat) => DropdownMenuItem(
                              child: Text(stat),
                              value: stat,
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() {
                      _status = val!;
                      _fetchLeaveRequests();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
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
                                      (_) => LeaveRequestDetailPage(
                                        leaveId: req['id'],
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              child: ListTile(
                                title: Text(req['fullname']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dept: ${req['department']}'),
                                    Text('Type: ${req['leave_type']}'),
                                    Text(
                                      'Date: ${req['start_date']} - ${req['end_date']}',
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
