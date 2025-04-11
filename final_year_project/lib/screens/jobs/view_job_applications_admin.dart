import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class JobApplicationsPage extends StatefulWidget {
  @override
  _JobApplicationsPageState createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  List<dynamic> applications = [];
  List<dynamic> filteredApplications = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  final String baseUrl = 'https://sanerylgloann.co.ke/EmployeeManagement/';

  @override
  void initState() {
    super.initState();
    fetchApplications();
    searchController.addListener(applySearchFilter);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchApplications() async {
    final response = await http.get(
      Uri.parse('${baseUrl}view_job_applications_admin.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          applications = data['data'];
          filteredApplications = applications;
          isLoading = false;
        });
      }
    }
  }

  void applySearchFilter() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredApplications =
          applications.where((app) {
            final title = app['job_title']?.toLowerCase() ?? '';
            final status = app['status']?.toLowerCase() ?? '';
            final dept = app['department']?.toLowerCase() ?? '';
            return title.contains(query) ||
                status.contains(query) ||
                dept.contains(query);
          }).toList();
    });
  }

  void updateStatus(int id, String status, String remarks) async {
    final response = await http.post(
      Uri.parse('${baseUrl}update_job_applications.php'),
      body: {'id': id.toString(), 'status': status, 'remarks': remarks},
    );

    final data = json.decode(response.body);
    if (data['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated successfully!')));
      fetchApplications();
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
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Job Title: ${application['job_title']}'),
                  Text('Full Name: ${application['full_name']}'),
                  SizedBox(height: 8),
                  Text(
                    'Application Letter: ${application['application_text']}',
                  ),
                  SizedBox(height: 8),
                  Text('Submission Date: ${application['submission_date']}'),
                  SizedBox(height: 8),
                  if (application['resume_url'] != null)
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse(application['resume_url']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open resume')),
                          );
                        }
                      },
                      child: Text(
                        'Open Resume',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  SizedBox(height: 8),
                  if (application['supporting_document_url'] != null)
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse(
                          application['supporting_document_url'],
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open document')),
                          );
                        }
                      },
                      child: Text(
                        'Open Supporting Document',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: remarksController,
                    decoration: InputDecoration(labelText: 'Remarks'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Reject'),
                onPressed: () {
                  updateStatus(
                    int.parse(application['id'].toString()),
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
                    int.parse(application['id'].toString()),
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

  Future<void> generateApplicationsReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build:
            (pw.Context context) => [
              pw.Text(
                'Job Applications Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Job No', 'Full Name', 'Status', 'Submitted'],
                data:
                    filteredApplications.map((app) {
                      return [
                        app['jobno'].toString(),
                        app['full_name'],
                        app['status'] ?? 'Pending',
                        app['submission_date'],
                      ];
                    }).toList(),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Applications'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Report',
            onPressed:
                filteredApplications.isEmpty
                    ? null
                    : generateApplicationsReport,
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by title, department, or status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredApplications.length,
                      itemBuilder: (context, index) {
                        final app = filteredApplications[index];
                        return Card(
                          child: ListTile(
                            title: Text(app['full_name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Job No: ${app['jobno']}'),
                                Text('Title: ${app['job_title']}'),
                                Text(
                                  'Department: ${app['department'] ?? 'N/A'}',
                                ),
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
                  ),
                ],
              ),
    );
  }
}
