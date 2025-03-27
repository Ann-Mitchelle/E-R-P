class Training {
  final String trainingId;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String duration;
  final String location;
  final List<String> participants; // Added participants

  Training({
    required this.trainingId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.location,
    required this.participants, // Include participants
  });

  // Factory constructor to convert JSON response into a Training object
  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      trainingId: json['training_id'] ?? '',
      title: json['title'] ?? 'N/A',
      description: json['description'] ?? 'N/A',
      startDate: json['start_date'] ?? 'N/A',
      endDate: json['end_date'] ?? 'N/A',
      duration: json['duration'] ?? '0',
      location: json['location'] ?? 'N/A',
      participants: List<String>.from(json['participants'] ?? []), // Convert JSON array to list
    );
  }
}
