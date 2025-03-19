import 'package:final_year_project/screens/jobs/job_details.dart';
import 'package:final_year_project/screens/jobs/job_service.dart';
import 'package:flutter/material.dart';
import 'job_model.dart';

class ViewJobsPage extends StatefulWidget {
  @override
  _ViewJobsPageState createState() => _ViewJobsPageState();
}

class _ViewJobsPageState extends State<ViewJobsPage> {
  late Future<List<Job>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _fetchJobs();
  }

  Future<List<Job>> _fetchJobs() async {
    final jobList = await ApiJobsService.fetchJobs();
    return jobList.map((jobData) => Job.fromJson(jobData)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Advertisements")),
      body: FutureBuilder<List<Job>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading jobs"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No job advertisements found"));
          }

          final jobs = snapshot.data!;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    job.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Department: ${job.department}"),
                      Text("Employment: ${job.employmentType}"),
                      Text("Deadline: ${job.deadline}"),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailPage(job: job),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
