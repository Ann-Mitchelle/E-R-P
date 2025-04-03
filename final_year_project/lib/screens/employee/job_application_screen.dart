
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_year_project/screens/jobs/job_model.dart';

class JobApplicationScreen extends StatefulWidget {
  final Job job;

  JobApplicationScreen({required this.job});

  @override
  _JobApplicationScreenState createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _applicationTextController = TextEditingController();

  String fullName = "";
  String email = "";
  String empNo = "";

  PlatformFile? resumeFile;
  PlatformFile? supportingDocumentFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _applicationTextController.dispose();
    super.dispose();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String firstName = prefs.getString('firstname') ?? '';
      String secondName = prefs.getString('secondname') ?? '';
      print("Retrieved First Name: $firstName");
      print("Retrieved Second Name: $secondName");

      fullName = "$firstName $secondName"; // Concatenate first and last name
      email = prefs.getString('email') ?? 'Unknown';
      empNo = prefs.getString('emp_no') ?? '';
    });
  }

  // File Picker
  Future<void> pickFile(String fileType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: kIsWeb, // Ensures we get `bytes` on Web
      );

      if (result != null) {
        setState(() {
          if (fileType == "resume") {
            resumeFile = result.files.single;
          } else if (fileType == "supporting_document") {
            supportingDocumentFile = result.files.single;
          }
        });
      } else {
        print('File selection canceled');
      }
    } catch (e) {
      print('Error selecting file: $e');
    }
  }

  // Submit Application
  // Submit Application
  Future<void> submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      var uri = Uri.parse(
        'https://sanerylgloann.co.ke/EmployeeManagement/submit_application.php',
      );
      var request = http.MultipartRequest('POST', uri);

      request.fields['jobno'] = widget.job.jobNo.toString();
      request.fields['emp_no'] = empNo;
      request.fields['full_name'] = fullName; // Add the full name field here
      request.fields['application_text'] = _applicationTextController.text;

      // Attach resume file if selected
      if (resumeFile != null) {
        if (kIsWeb) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'resume',
              resumeFile!.bytes!,
              filename: resumeFile!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'resume',
              resumeFile!.path!,
              filename: path.basename(resumeFile!.path!),
            ),
          );
        }
      }

      // Attach supporting document file if selected
      if (supportingDocumentFile != null) {
        if (kIsWeb) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'supporting_document',
              supportingDocumentFile!.bytes!,
              filename: supportingDocumentFile!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'supporting_document',
              supportingDocumentFile!.path!,
              filename: path.basename(supportingDocumentFile!.path!),
            ),
          );
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Application Submitted'),
              content: Text(
                'Your application for "${widget.job.title}" has been successfully submitted.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception(
          'Failed to submit application. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error submitting application: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.job.title}'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Full Name: $fullName', style: TextStyle(fontSize: 16)),
              Text('Email: $email', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              TextFormField(
                controller: _applicationTextController,
                decoration: InputDecoration(labelText: 'Formal Application'),
                maxLines: 5,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Please enter your application text'
                            : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => pickFile("resume"),
                child: Text(
                  resumeFile == null ? 'Upload Resume' : 'Resume Selected',
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => pickFile("supporting_document"),
                child: Text(
                  supportingDocumentFile == null
                      ? 'Upload Supporting Document'
                      : 'Document Selected',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitApplication,
                child: Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
