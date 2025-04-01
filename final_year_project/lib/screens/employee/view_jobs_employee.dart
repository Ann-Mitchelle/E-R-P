import 'package:final_year_project/screens/employee/job_application_screen.dart';
import 'package:final_year_project/screens/jobs/job_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Assuming the Job model is in job_model.dart

class JobsScreen extends StatefulWidget {
  @override
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late Future<List<Job>> futureJobs;

  @override
  void initState() {
    super.initState();
    futureJobs = fetchAvailableJobs();
  }

  // Fetch available jobs
  Future<List<Job>> fetchAvailableJobs() async {
    final response = await http.get(
      Uri.parse('https://sanerylgloann.co.ke/EmployeeManagement/get_jobs.php'),
    );

    if (response.statusCode == 200) {
      // Assuming the API returns a JSON object with a 'data' key containing the job list
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> jobsData =
          responseData['data']; // Extract the 'data' list
      return jobsData.map((item) => Job.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  // Show job details in a popup
  void showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(job.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${job.description}'),
              SizedBox(height: 8),
              Text('Location: ${job.location}'),
              SizedBox(height: 8),
              Text('Department: ${job.department}'),
              SizedBox(height: 8),
              Text('deadline: ${job.deadline}'),
              SizedBox(height: 8),
              Text('Qualifications: ${job.qualifications}'),
              SizedBox(height: 8),
              Text('Employment Type: ${job.employmentType}'),
              SizedBox(height: 8),
              Text('Posted date: ${job.postedDate}'),
              SizedBox(height: 8),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to job application screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobApplicationScreen(job: job),
                  ),
                );
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Jobs'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Job>>(
        future: futureJobs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No available jobs.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final job = snapshot.data![index];
                return ListTile(
                  title: Text(job.title),
                  subtitle: Text(job.location),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => showJobDetails(job), // Show job details on tap
                );
              },
            );
          }
        },
      ),
    );
  }
}
