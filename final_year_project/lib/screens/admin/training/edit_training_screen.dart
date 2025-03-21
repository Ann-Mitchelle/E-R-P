import 'package:flutter/material.dart';
import 'training_model.dart';
import 'training_service.dart';

class EditTrainingScreen extends StatefulWidget {
  final Training training;

  EditTrainingScreen({required this.training});

  @override
  _EditTrainingScreenState createState() => _EditTrainingScreenState();
}

class _EditTrainingScreenState extends State<EditTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _locationController;

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
  }

  void _updateTraining() async {
    if (_formKey.currentState!.validate()) {
      bool success = await ApiTrainingService.editTraining(
        trainingId: widget.training.trainingId,
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        location: _locationController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Training updated successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update training")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Training")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
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
