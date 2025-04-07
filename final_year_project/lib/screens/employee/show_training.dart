import 'package:final_year_project/screens/admin/training/training_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrainingsScreen extends StatefulWidget {
  @override
  _TrainingsScreenState createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  late Future<List<Training>> futureTrainings;

  @override
  void initState() {
    super.initState();
    futureTrainings = fetchUpcomingTrainings();
  }

  // Fetch the list of upcoming trainings
  Future<List<Training>> fetchUpcomingTrainings() async {
    final response = await http.get(
      Uri.parse(
        "https://sanerylgloann.co.ke/EmployeeManagement/get_trainings.php",
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('trainings')) {
        List<dynamic> trainingList = data['trainings'];
        return trainingList.map((item) => Training.fromJson(item)).toList();
      } else {
        throw Exception('No trainings found in response');
      }
    } else {
      throw Exception('Failed to load trainings');
    }
  }

  // Show training details with participants
  void showTrainingDetails(Training training) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(training.title),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${training.description}'),
                  SizedBox(height: 8),
                  Text('Start Date: ${training.startDate}'),
                  Text('End Date: ${training.endDate}'),
                  Text('Duration: ${training.duration}'),
                  Text('Location: ${training.location}'),
                  SizedBox(height: 10),
                  Text(
                    "Training participants:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (training.participants.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: training.participants.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text("• ${training.participants[index]}"),
                        );
                      },
                    )
                  else
                    Text("No participants."),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Trainings'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Training>>(
        future: futureTrainings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No upcoming trainings.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final training = snapshot.data![index];
                return ListTile(
                  title: Text(training.title),
                  subtitle: Text(
                    '${training.startDate} - ${training.location}',
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => showTrainingDetails(training),
                );
              },
            );
          }
        },
      ),
    );
  }
}
