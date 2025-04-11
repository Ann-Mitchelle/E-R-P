import 'package:final_year_project/screens/admin/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum LeaveType { Annual, Sick, Maternity, paternity }

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
  bool _isSubmitting = false;

  Map<String, int?> leaveBalances = {
    "Annual": 30,
    "Sick": 14,
    "Maternity": 90,
    "paternity": 14,
  };

  String? empNo;

  final List<DateTime> kenyanHolidays = [
    DateTime(DateTime.now().year, 1, 1), // New Year's Day
    DateTime(DateTime.now().year, 4, 7), // Good Friday 2025 (adjust each year)
    DateTime(
      DateTime.now().year,
      4,
      10,
    ), // Easter Monday 2025 (adjust each year)
    DateTime(DateTime.now().year, 5, 1), // Labour Day
    DateTime(DateTime.now().year, 6, 1), // Madaraka Day
    DateTime(DateTime.now().year, 10, 10), // Huduma Day
    DateTime(DateTime.now().year, 10, 20), // Mashujaa Day
    DateTime(DateTime.now().year, 12, 12), // Jamhuri Day
    DateTime(DateTime.now().year, 12, 25), // Christmas
    DateTime(DateTime.now().year, 12, 26), // Boxing Day
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empNo = prefs.getString("emp_no");
    });

    if (empNo != null) {
      _fetchLeaveBalances(empNo!);
    }
  }

  Future<void> _fetchLeaveBalances(String empNo) async {
    try {
      UserService userService = UserService();
      Map<String, int?> balances = await userService.getLeaveBalances(empNo);
      setState(() {
        leaveBalances = balances;
      });
    } catch (e) {
      print("Error fetching leave balances: $e");
      _showError("Failed to load leave balances");
    }
  }

  int calculateBusinessDays(DateTime start, DateTime end) {
    int businessDays = 0;
    DateTime current = start;

    while (!current.isAfter(end)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday &&
          !kenyanHolidays.any(
            (h) =>
                h.day == current.day &&
                h.month == current.month &&
                h.year == current.year,
          )) {
        businessDays++;
      }
      current = current.add(Duration(days: 1));
    }

    return businessDays;
  }

  void _pickDate(BuildContext context, bool isStartDate) async {
    DateTime now = DateTime.now();
    DateTime minDate =
        (_selectedLeaveType == LeaveType.Sick)
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
          _endDate = null;
        } else {
          _endDate = pickedDate;
        }

        if (_startDate != null && _endDate != null) {
          _leaveDuration = calculateBusinessDays(_startDate!, _endDate!);
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

    int leaveDays = _leaveDuration!;
    String leaveTypeKey = _selectedLeaveType.toString().split('.').last;
    leaveTypeKey = leaveTypeKey[0].toUpperCase() + leaveTypeKey.substring(1);
    int maxDays = leaveBalances[leaveTypeKey] ?? 0;

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

    request.fields['emp_no'] = empNo.toString();
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

      if (responseData.trim().startsWith('<')) {
        _showError(
          "Server returned an HTML response. Check API URL or server error.",
        );
        return;
      }

      var jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        _showSuccess(jsonResponse["message"]);
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
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
                (entry) => Text(
                  "${entry.key.toUpperCase()}: ${entry.value ?? 0} days",
                ),
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
                        child: Text(type.toString().split('.').last),
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
                label: Text(
                  _documentPath == null
                      ? "Attach Document"
                      : "Document Selected",
                ),
              ),
              SizedBox(height: 20),
              Center(
                child:
                    _isSubmitting
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _submitApplication,
                          child: Text("Submit Leave Application"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: TextStyle(fontSize: 16),
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
