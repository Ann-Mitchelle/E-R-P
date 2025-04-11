import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'training_model.dart';
import 'training_service.dart';

class EditTrainingScreen extends StatefulWidget {
  final Training training;

  EditTrainingScreen({required this.training});

  @override
  _EditTrainingScreenState createState() => _EditTrainingScreenState();
}

class _EditTrainingScreenState extends State<EditTrainingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _locationController;
  late TextEditingController _durationController;
  late List<String> _participants;
  late Future<void> _employeesFuture;
  List<Map<String, String>> employees = [];
  String? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.training.title);
    _descriptionController = TextEditingController(
      text: widget.training.description,
    );
    _startDateController = TextEditingController(
      text: widget.training.startDate,
    );
    _endDateController = TextEditingController(text: widget.training.endDate);
    _locationController = TextEditingController(text: widget.training.location);
    _durationController = TextEditingController(text: widget.training.duration);
    _participants = List<String>.from(widget.training.participants);

    _employeesFuture =
        fetchEmployees(); // Fetch employees when the screen initializes
  }

  Future<void> fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://sanerylgloann.co.ke/EmployeeManagement/get_employees.php",
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          // Ensure you're using the proper structure for the employee data
          employees =
              data.map((json) {
                return {
                  "emp_no": json["emp_no"].toString(),
                  "name": json["name"].toString(),
                };
              }).toList();
        });
      } else {
        print("Failed to load employees: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }

  void _saveTraining() async {
    Training updatedTraining = Training(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
      location: _locationController.text,
      participants: _participants,
      trainingId: widget.training.trainingId, // 🟢 Use existing trainingId
      duration: _durationController.text,
    );

    bool success = await ApiTrainingService.updateTraining(updatedTraining);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Training updated successfully")));
      Navigator.pop(context, updatedTraining);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update training")));
    }
  }

  void _addParticipant(String employeeName) {
    setState(() {
      if (!_participants.contains(employeeName)) {
        _participants.add(employeeName);
      }
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.toLocal()}".split(
              ' ',
            )[0]; // Formatting the date as YYYY-MM-DD
        _calculateDuration(); // Recalculate the duration when date changes
      });
    }
  }

  void _calculateDuration() {
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty) {
      DateTime startDate = DateTime.parse(_startDateController.text);
      DateTime endDate = DateTime.parse(_endDateController.text);
      int difference = endDate.difference(startDate).inDays + 1;
      _durationController.text = "$difference days";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Training")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, _startDateController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _startDateController,
                    decoration: InputDecoration(labelText: "Start Date"),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, _endDateController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _endDateController,
                    decoration: InputDecoration(labelText: "End Date"),
                  ),
                ),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location"),
              ),
              TextField(
                controller: _durationController,
                decoration: InputDecoration(labelText: "Duration"),
                readOnly: true,
              ),
              SizedBox(height: 20),
              Text(
                "Participants:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_participants.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _participants.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_participants[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.remove, color: Colors.red),
                        onPressed: () => _removeParticipant(index),
                      ),
                    );
                  },
                ),
              if (_participants.isEmpty) Text("No participants added yet"),
              SizedBox(height: 10),
              Text(
                "Select Employees to Add as Participants:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FutureBuilder(
                future: _employeesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching employees"));
                  }

                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedEmployee,
                        decoration: InputDecoration(
                          labelText: 'Select Participant',
                        ),
                        items:
                            employees.map((employee) {
                              return DropdownMenuItem<String>(
                                value: employee["emp_no"],
                                child: Text(employee["name"]!),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedEmployee = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedEmployee != null &&
                              !_participants.contains(_selectedEmployee)) {
                            var employee = employees.firstWhere(
                              (emp) => emp["emp_no"] == _selectedEmployee,
                            );
                            _addParticipant(employee["name"]!);
                          }
                        },
                        child: Text("Add Participant"),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTraining,
                child: Text("Save Training"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
