class Job {
  final int jobNo;
  final String title;
  final String department;
  final String location;
  final String employmentType;
  final String description;
  final String qualifications;
  final String deadline;
  final String postedDate;

  Job({
    required this.jobNo,
    required this.title,
    required this.department,
    required this.location,
    required this.employmentType,
    required this.description,
    required this.qualifications,
    required this.deadline,
    required this.postedDate,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobNo: int.parse(json["jobno"]),
      title: json["job_title"],
      department: json["department"],
      location: json["location"],
      employmentType: json["employment_type"],
      description: json["description"],
      qualifications: json["qualifications"],
      deadline: json["deadline"],
      postedDate: json["posted_date"],
    );
  }
}
