
import 'package:final_year_project/screens/admin/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum LeaveType { annual, sick, maternity, paternity }

class LeaveApplicationScreen extends StatefulWidget {
  
  @override
  _LeaveApplicationScreenState createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _note;
  String? _documentPath;
  int? _leaveDuration;
  bool _isSubmitting = false; // Loading indicator

  Map<String, int> leaveBalances = {
    "annual": 30,
    "sick": 14,
    "maternity": 90,
    "paternity": 14,
  };
 
  

  @override
  void initState() {
    super.initState();
    _fetchLeaveBalances();
    
  
  }

  // Fetch leave balances from API
  void _fetchLeaveBalances() async {
    final url = Uri.parse(
      "https://sanerylgloann.co.ke/EmployeeManagement/get_leave_balances.php",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type":
              "application/x-www-form-urlencoded", // Ensures proper encoding
        },
      );

      print("Response Body: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("Parsed JSON: $jsonResponse"); // Debugging

        if (jsonResponse["success"] == 1) {
          List<dynamic> leaveData = jsonResponse["leave_balances"];
          print("Leave Data: $leaveData"); // Debugging

          if (leaveData.isNotEmpty) {
            setState(() {
              leaveBalances = {
                "annual":
                    int.tryParse(leaveData[0]["Annual"].toString()) ?? 0,
                "sick":
                    int.tryParse(leaveData[0]["Sick"].toString()) ?? 0,
                "maternity":
                    int.tryParse(leaveData[0]["Maternity"].toString()) ??
                    0,
                "paternity":
                    int.tryParse(leaveData[0]["paternity"].toString()) ??
                    0,
              };
            });
          }
        } else {
          _showError(jsonResponse["message"]);
        }
      } else {
        _showError("Failed to load leave balances. Server Error.");
      }
    } catch (e) {
      _showError("Error fetching data: $e");
    }
  }


  void _pickDate(BuildContext context, bool isStartDate) async {
    DateTime now = DateTime.now();
    DateTime minDate =
        (_selectedLeaveType == LeaveType.sick)
            ? now
            : now.add(Duration(days: 7));

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          _endDate = null; // Reset end date when start date changes
        } else {
          _endDate = pickedDate;
        }

        if (_startDate != null && _endDate != null) {
          _leaveDuration = _endDate!.difference(_startDate!).inDays + 1;
        }
      });
    }
  }

  void _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _documentPath = result.files.single.path;
      });
    }
  }

  void _submitApplication() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) {
      _showError("Please fill in all required fields.");
      return;
    }

    int leaveDays = _endDate!.difference(_startDate!).inDays + 1;
    int maxDays =
        leaveBalances[_selectedLeaveType.toString().split('.').last] ?? 0;

    if (leaveDays > maxDays) {
      _showError("Cannot exceed $maxDays days for this leave type.");
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isSubmitting = true;
    });

    var request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "https://sanerylgloann.co.ke/EmployeeManagement/apply_leave.php",
      ),
    );

    request.fields['emp_no'] = "EMP001"; // Replace with actual employee ID
    request.fields['leave_type'] =
        _selectedLeaveType.toString().split('.').last;
    request.fields['start_date'] = _startDate.toString();
    request.fields['end_date'] = _endDate.toString();
    request.fields['duration'] = leaveDays.toString();
    request.fields['notes'] = _note ?? "";

    if (_documentPath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('document', _documentPath!),
      );
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      print("Response: $response.body");
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        _showSuccess(jsonResponse["message"]);
      } else {
        _showError("Failed to submit: ${jsonResponse['message']}");
      }
    } catch (e) {
      _showError("Error submitting leave request: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Apply for Leave"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Leave Balances:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...leaveBalances.entries.map(
                (entry) =>
                    Text("${entry.key.toUpperCase()}: ${entry.value} days"),
              ),
              SizedBox(height: 16),

              Text("Select Leave Type"),
              DropdownButtonFormField<LeaveType>(
                value: _selectedLeaveType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items:
                    LeaveType.values.map((LeaveType type) {
                      return DropdownMenuItem<LeaveType>(
                        value: type,
                        child: Text(
                          type.toString().split('.').last.toUpperCase(),
                        ),
                      );
                    }).toList(),
                onChanged: (LeaveType? newValue) {
                  setState(() {
                    _selectedLeaveType = newValue;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select a leave type' : null,
              ),

              SizedBox(height: 16),
              Text("Start Date"),
              ElevatedButton(
                onPressed: () => _pickDate(context, true),
                child: Text(
                  _startDate == null
                      ? "Pick a start date"
                      : DateFormat.yMMMd().format(_startDate!),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),

              SizedBox(height: 16),
              Text("End Date"),
              ElevatedButton(
                onPressed: () => _pickDate(context, false),
                child: Text(
                  _endDate == null
                      ? "Pick an end date"
                      : DateFormat.yMMMd().format(_endDate!),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),

              if (_leaveDuration != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Leave Duration: $_leaveDuration days",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),

              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Additional Note (Optional)",
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _note = value,
              ),

              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickDocument,
                icon: Icon(Icons.attach_file),
                label: Text(_documentPath ?? "Attach Supporting Document"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),

              SizedBox(height: 24),
              Center(
                child:
                    _isSubmitting
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _submitApplication,
                          child: Text("Submit Leave Application"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
