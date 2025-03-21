import 'dart:convert';
import 'package:final_year_project/screens/admin/training/training_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrainingListScreen extends StatefulWidget {
  @override
  _TrainingListScreenState createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends State<TrainingListScreen> {
  List trainings = [];

  @override
  void initState() {
    super.initState();
    fetchTrainings();
  }

  Future<void> fetchTrainings() async {
    var response = await http.get(
      Uri.parse(
        "https://sanerylgloann.co.ke/EmployeeManagement/get_trainings.php",
      ),
    );
    var data = jsonDecode(response.body);

    if (data['success']) {
      setState(() {
        trainings = data['trainings'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trainings")),
      body: ListView.builder(
        itemCount: trainings.length,
        itemBuilder: (context, index) {
          var training = trainings[index];
          return ListTile(
            title: Text(training['title']),
            subtitle: Text(training['start_date']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          TrainingDetailScreen(trainingId: training['training_id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
