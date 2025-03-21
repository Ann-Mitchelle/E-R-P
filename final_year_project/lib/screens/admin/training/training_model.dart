class Training {
  final String trainingId;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String location;

  Training({
    required this.trainingId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
  });

  // Factory constructor to convert JSON response into a Training object
  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      trainingId: json['training_id'] ?? '',
      title: json['title'] ?? 'N/A',
      description: json['description'] ?? 'N/A',
      startDate: json['start_date'] ?? 'N/A',
      endDate: json['end_date'] ?? 'N/A',
      location: json['location'] ?? 'N/A',
    );
  }
}
