import 'package:flutter/material.dart';
import 'training_model.dart';
import 'training_service.dart';
import 'edit_training_screen.dart';

class TrainingDetailScreen extends StatefulWidget {
  final String trainingId;

  TrainingDetailScreen({required this.trainingId});

  @override
  _TrainingDetailScreenState createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  late Future<Training?> _trainingFuture;

  @override
  void initState() {
    super.initState();
    _trainingFuture = ApiTrainingService.fetchTraining(widget.trainingId);
  }

  void _deleteTraining() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Training"),
          content: Text(
            "Are you sure you want to delete this training session? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      bool success = await ApiTrainingService.deleteTraining(widget.trainingId);
      print("Delete API Response: $success");
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Training deleted successfully")),
        );
        Navigator.pop(context, true); // Go back and refresh list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete training")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Training Details")),
      body: FutureBuilder<Training?>(
        future: _trainingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData)
            return Center(child: Text("No training details available"));

          Training training = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title: ${training.title}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Description: ${training.description}"),
                SizedBox(height: 10),
                Text("Start Date: ${training.startDate}"),
                SizedBox(height: 10),
                Text("End Date: ${training.endDate}"),
                SizedBox(height: 10),
                Text("Location: ${training.location}"),
                SizedBox(height: 20),
                Text(
                  "Training participants:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (training.participants.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      itemBuilder:
                          (context, index) => Text(
                            training.participants[index].substring(
                              0,
                              training.participants[index].indexOf('|'),
                            ),
                          ),
                      itemCount: training.participants.length,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text("Edit"),
                      onPressed: () {
                        print(
                          "Participants in TrainingDetailScreen: ${training.participants}",
                        ); // Debugging
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EditTrainingScreen(training: training),
                          ),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete, color: Colors.white),
                      label: Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _deleteTraining,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
