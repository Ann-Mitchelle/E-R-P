import 'package:flutter/material.dart';
import 'edit_job_page.dart';
import 'job_model.dart';
import 'job_service.dart';

class JobDetailPage extends StatelessWidget {
  final Job job;

  JobDetailPage({required this.job});

  void _deleteJob(BuildContext context) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Job"),
          content: Text(
            "Are you sure you want to delete this job? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      bool success = await ApiJobsService.deleteJob(job.jobNo);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Job deleted successfully")));
        Navigator.pop(context, true); // Go back and refresh job list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete job")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Department: ${job.department}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Location: ${job.location}", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(
                "Employment Type: ${job.employmentType}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Deadline: ${job.deadline}",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              SizedBox(height: 16),
              Text(
                "Job Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(job.description, style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Text(
                "Qualifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(job.qualifications, style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Text(
                "Posted Date: ${job.postedDate}",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text("Edit"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditJobPage(job: job),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete, color: Colors.white),
                    label: Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _deleteJob(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
