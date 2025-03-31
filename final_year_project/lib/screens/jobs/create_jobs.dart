import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddJobAdvertisement extends StatefulWidget {
  @override
  _AddJobAdvertisementState createState() => _AddJobAdvertisementState();
}

class _AddJobAdvertisementState extends State<AddJobAdvertisement> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobLocationController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _qualificationsController =
      TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  // Dropdown values
  String? _selectedDepartment;
  String? _selectedEmploymentType;

  // Options for dropdowns
  final List<String> departments = [
    "IT Department",
    "Finance",
    "Human Resources",
    "Operations",
    "Marketing",
  ];

  final List<String> employmentTypes = ["Permanent", "Contract", "Part-Time"];

  // Function to submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(
        "https://sanerylgloann.co.ke/EmployeeManagement/add_jobs.php",
      );

      final response = await http.post(
        url,
        body: jsonEncode({
          "job_title": _jobTitleController.text,
          "department": _selectedDepartment,
          "location": _jobLocationController.text,
          "employment_type": _selectedEmploymentType,
          "description": _jobDescriptionController.text,
          "qualifications": _qualificationsController.text,
          "deadline": _deadlineController.text,
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Job Advertisement Added Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add job advertisement"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Job Advertisement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _jobTitleController,
                  decoration: InputDecoration(labelText: "Job Title"),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Please enter job title" : null,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Department"),
                  value: _selectedDepartment,
                  items:
                      departments.map((dept) {
                        return DropdownMenuItem(value: dept, child: Text(dept));
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedDepartment = value),
                  validator:
                      (value) =>
                          value == null ? "Please select a department" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _jobLocationController,
                  decoration: InputDecoration(labelText: "Job Location"),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Please enter job location" : null,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Employment Type"),
                  value: _selectedEmploymentType,
                  items:
                      employmentTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged:
                      (value) =>
                          setState(() => _selectedEmploymentType = value),
                  validator:
                      (value) =>
                          value == null
                              ? "Please select employment type"
                              : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _jobDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: "Job Description"),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? "Please enter job description"
                              : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _qualificationsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Required Qualifications",
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Please enter qualifications" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _deadlineController,
                  decoration: InputDecoration(
                    labelText: "Application Deadline",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _deadlineController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                  validator:
                      (value) =>
                          value!.isEmpty ? "Please select a deadline" : null,
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text("Add Job Advertisement"),
                   
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Set background color
                        foregroundColor: Colors.white, // Text color
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
