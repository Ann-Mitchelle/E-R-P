import 'package:final_year_project/screens/jobs/job_model.dart';
import 'package:final_year_project/screens/jobs/job_service.dart';
import 'package:flutter/material.dart';


class EditJobPage extends StatefulWidget {
  final Job job;

  EditJobPage({required this.job});

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _departmentController;
  late TextEditingController _locationController;
  late TextEditingController _employmentTypeController;
  late TextEditingController _descriptionController;
  late TextEditingController _qualificationsController;
  late TextEditingController _deadlineController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _departmentController = TextEditingController(text: widget.job.department);
    _locationController = TextEditingController(text: widget.job.location);
    _employmentTypeController = TextEditingController(
      text: widget.job.employmentType,
    );
    _descriptionController = TextEditingController(
      text: widget.job.description,
    );
    _qualificationsController = TextEditingController(
      text: widget.job.qualifications,
    );
    _deadlineController = TextEditingController(text: widget.job.deadline);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _employmentTypeController.dispose();
    _descriptionController.dispose();
    _qualificationsController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _updateJob() async {
    if (_formKey.currentState!.validate()) {
      bool success = await ApiJobsService.editJob(
        jobNo: widget.job.jobNo,
        title: _titleController.text,
        department: _departmentController.text,
        location: _locationController.text,
        employmentType: _employmentTypeController.text,
        description: _descriptionController.text,
        qualifications: _qualificationsController.text,
        deadline: _deadlineController.text,
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Job updated successfully")));
        Navigator.pop(context, true); // Return to refresh list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update job")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Job")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Job Title"),
              ),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(labelText: "Department"),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location"),
              ),
              TextFormField(
                controller: _employmentTypeController,
                decoration: InputDecoration(labelText: "Employment Type"),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              TextFormField(
                controller: _qualificationsController,
                decoration: InputDecoration(labelText: "Qualifications"),
                maxLines: 3,
              ),
              TextFormField(
                controller: _deadlineController,
                decoration: InputDecoration(labelText: "Deadline"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
               
                onPressed: _updateJob, 
                 style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white,
                ),
                child: Text("Update Job")),
            ],
          ),
        ),
      ),
    );
  }
}
