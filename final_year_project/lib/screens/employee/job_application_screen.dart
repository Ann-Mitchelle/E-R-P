import 'package:final_year_project/screens/jobs/job_model.dart';
import 'package:flutter/material.dart';

class JobApplicationScreen extends StatefulWidget {
  final Job job;

  JobApplicationScreen({required this.job});

  @override
  _JobApplicationScreenState createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _resumeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  // Simulating form submission
  void submitApplication() {
    if (_formKey.currentState?.validate() ?? false) {
      // Submit job application
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Application Submitted'),
              content: Text(
                'Your application for the job "${widget.job.title}" has been submitted.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context); // Go back to the jobs screen
                  },
                  child: Text('Close'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Job'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                'Applying for: ${widget.job.title}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _resumeController,
                decoration: InputDecoration(labelText: 'Resume (Link or File)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a link or file for your resume';
                  }
                  return null;
                },
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
