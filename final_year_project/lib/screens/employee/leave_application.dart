import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApplyLeaveScreen extends StatefulWidget {
  @override
  _ApplyLeaveScreenState createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  String selectedLeaveType = "Annual";
  DateTime? startDate;
  DateTime? endDate;
  int duration = 0;
  File? supportingDocument;
  TextEditingController notesController = TextEditingController();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        supportingDocument = File(result.files.single.path!);
      });
    }
  }

  void _pickStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 7)), // Constraint
      firstDate: DateTime.now().add(
        selectedLeaveType == "Sick" || selectedLeaveType == "Compassionate"
            ? Duration(days: 0)
            : Duration(days: 7),
      ),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        endDate = null; // Reset end date
        duration = 0;
      });
    }
  }

  void _pickEndDate(BuildContext context) async {
    if (startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pick start date first!")));
      return;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate!,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
        duration = endDate!.difference(startDate!).inDays + 1;
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Select leave dates.")));
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://yourdomain.com/apply_leave.php"),
    );
    request.fields['employee_id'] = "1"; // Replace with actual employee ID
    request.fields['leave_type'] = selectedLeaveType;
    request.fields['start_date'] = startDate.toString();
    request.fields['end_date'] = endDate.toString();
    request.fields['duration'] = duration.toString();
    request.fields['notes'] = notesController.text;

    if (supportingDocument != null) {
      request.files.add(
        await http.MultipartFile.fromPath('document', supportingDocument!.path),
      );
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    var result = json.decode(responseBody);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result["message"])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apply Leave")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Leave Type:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedLeaveType,
              items:
                  ["Maternity", "Paternity", "Annual", "Sick", "Compassionate"]
                      .map((e) => DropdownMenuItem(child: Text(e), value: e))
                      .toList(),
              onChanged:
                  (val) => setState(() {
                    selectedLeaveType = val!;
                    startDate = null;
                    endDate = null;
                    duration = 0;
                  }),
            ),
            SizedBox(height: 20),

            Text("Start Date:", style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () => _pickStartDate(context),
              child: Text(
                startDate == null
                    ? "Select Start Date"
                    : "${startDate!.toLocal()}".split(' ')[0],
              ),
            ),
            SizedBox(height: 10),

            Text("End Date:", style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () => _pickEndDate(context),
              child: Text(
                endDate == null
                    ? "Select End Date"
                    : "${endDate!.toLocal()}".split(' ')[0],
              ),
            ),
            SizedBox(height: 10),

            Text(
              "Duration: $duration days",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            TextFormField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: "Additional Notes (Optional)",
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: _pickFile,
              child: Text("Upload Supporting Document"),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: _submitLeaveRequest,
              child: Text("Submit Leave Request"),
            ),
          ],
        ),
      ),
    );
  }
}
