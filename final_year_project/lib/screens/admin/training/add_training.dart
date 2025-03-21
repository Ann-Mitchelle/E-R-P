import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class AddTrainingPage extends StatefulWidget {
  @override
  _AddTrainingPageState createState() => _AddTrainingPageState();
}

class _AddTrainingPageState extends State<AddTrainingPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  List<dynamic> employees = []; // Stores employee data
  List<String> selectedParticipants = []; // Stores selected employee IDs

  final String apiUrl = "https://sanerylgloann.co.ke/EmployeeManagement/";

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  // Fetch employees from API
  Future<void> fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://sanerylgloann.co.ke/EmployeeManagement/get_employees.php",
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          print("No employees found.");
        } else {
          print("First employee: ${data[0]}");
        }
        employees =
            data.map((json) {
              return {
                "emp_no": json["emp_no"], // Ensure correct key
                "name": json["name"],
              };
            }).toList();
        setState(() {}); // Refresh UI
      } else {
        print("Failed to load employees: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }

  // Function to pick date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  // Submit training details
  Future<void> _submitTraining() async {
    if (_formKey.currentState!.validate()) {
      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select start and end dates")),
        );
        return;
      }

      var data = {
        "title": titleController.text,
        "description": descriptionController.text,
        "start_date": DateFormat("yyyy-MM-dd").format(startDate!),
        "end_date": DateFormat("yyyy-MM-dd").format(endDate!),
        "duration": durationController.text,
        "location": locationController.text,
        "participants": jsonEncode(selectedParticipants),
        // "participants": selectedParticipants.join(
        //""",""",
        // ),
        //"participants":
        // selectedParticipants, // Send as List<String> // Converts List<String> to a single comma-separated String
        // Send selected IDs as a list
      };

      try {
        var response = await http.post(
          Uri.parse(
            "https://sanerylgloann.co.ke/EmployeeManagement/addtraining.php",
          ),
          // No jsonEncode
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: jsonEncode(data),
        );
        print(jsonEncode(data));

        var responseBody = jsonDecode(response.body);
        print("Response Body: $responseBody");
        if (response.statusCode == 200 && responseBody["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Training added successfully!")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(responseBody.toString())));
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to connect to server: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Training")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Training Title"),
                validator:
                    (value) => value!.isEmpty ? "Title is required" : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator:
                    (value) =>
                        value!.isEmpty ? "Description is required" : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location"),
                validator:
                    (value) => value!.isEmpty ? "Location is required" : null,
              ),
              TextFormField(
                controller: durationController,
                decoration: InputDecoration(
                  labelText: "Duration (e.g., 2 days)",
                ),
                validator:
                    (value) => value!.isEmpty ? "Duration is required" : null,
              ),
              ListTile(
                title: Text(
                  startDate == null
                      ? "Select Start Date"
                      : "Start Date: ${DateFormat.yMMMd().format(startDate!)}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text(
                  endDate == null
                      ? "Select End Date"
                      : "End Date: ${DateFormat.yMMMd().format(endDate!)}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              // Participants Dropdown
              Text("Select Participants"),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: null,
                items:
                    employees.map((employee) {
                      return DropdownMenuItem<String>(
                        value: employee["emp_no"],
                        child: Text(employee["name"]),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null &&
                      !selectedParticipants.contains(newValue)) {
                    setState(() {
                      selectedParticipants.add(newValue);
                    });
                  }
                },
              ),
              Wrap(
                children:
                    selectedParticipants.map((id) {
                      var employee = employees.firstWhere(
                        (emp) => emp["emp_no"] == id,
                      );
                      return Chip(
                        label: Text(employee["name"]),
                        onDeleted: () {
                          setState(() {
                            selectedParticipants.remove(id);
                          });
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTraining,
                child: Text("Submit Training"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
