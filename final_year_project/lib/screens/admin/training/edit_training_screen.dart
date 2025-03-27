import 'package:final_year_project/screens/admin/training/training_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EditTrainingScreen extends StatefulWidget {
  final Training training;

  EditTrainingScreen({required this.training});

  @override
  _EditTrainingPageState createState() => _EditTrainingPageState();
}

class _EditTrainingPageState extends State<EditTrainingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController durationController;

  DateTime? startDate;
  DateTime? endDate;
  List<dynamic> employees = [];
  List<String> selectedParticipants = [];

  final String apiUrl = "https://sanerylgloann.co.ke/EmployeeManagement/";

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing training data
    titleController = TextEditingController(text: widget.training.title);
    descriptionController = TextEditingController(
      text: widget.training.description,
    );

    locationController = TextEditingController(text: widget.training.location);
    durationController = TextEditingController(text: widget.training.duration);

    startDate = DateTime.tryParse(widget.training.startDate);
    endDate = DateTime.tryParse(widget.training.endDate);

    selectedParticipants = List<String>.from(
      widget.training.participants ?? [],
    );

    fetchEmployees();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> fetchEmployees() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/get_employees.php"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        employees =
            data.map((json) {
              return {"emp_no": json["emp_no"], "name": json["name"]};
            }).toList();
        setState(() {}); // Refresh UI
      } else {
        print("Failed to load employees: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (startDate ?? DateTime.now())
              : (endDate ?? DateTime.now()),
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

  Future<void> _updateTraining() async {
    if (_formKey.currentState!.validate()) {
      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select start and end dates")),
        );
        return;
      }

      var data = {
        "training_id":
            widget.training.trainingId, // Include training ID for update
        "title": titleController.text,
        "description": descriptionController.text,
        "start_date": DateFormat("yyyy-MM-dd").format(startDate!),
        "end_date": DateFormat("yyyy-MM-dd").format(endDate!),
        "duration": durationController.text,
        "location": locationController.text,
        "participants": jsonEncode(selectedParticipants),
      };

      try {
        var response = await http.post(
          Uri.parse("$apiUrl/update_training.php"),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: jsonEncode(data),
        );

        var responseBody = jsonDecode(response.body);
        if (response.statusCode == 200 && responseBody["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Training updated successfully!")),
          );
          Navigator.pop(context, true); // Go back and refresh the list
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
      appBar: AppBar(title: Text("Edit Training")),
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
                        orElse:
                            () => {
                              "name": "Unknown",
                            }, // Handle missing employee data
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
                onPressed: _updateTraining,
                child: Text("Update Training"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
