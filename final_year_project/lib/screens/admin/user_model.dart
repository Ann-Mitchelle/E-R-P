import 'package:final_year_project/screens/admin/dependant_model.dart';

class User {
  String? emp_no;
  String firstName;
  String secondName;
  String email;
  String phoneNumber;
  String department;
  String role;
  String image;
  String status;
  String? password;
  List<Dependant> dependants;
  int? annual;
  int? sick;
  int? maternity;
  int? paternity;

  User({
    this.emp_no,
    required this.firstName,
    required this.secondName,
    required this.email,
    required this.phoneNumber,
    required this.department,
    required this.role,
    required this.image,
    required this.status,
    this.password,
    required this.dependants,
    this.annual,
    this.sick,
    this.maternity,
    this.paternity,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstname': firstName,
      'secondname': secondName,
      'email': email,
      'phonenumber': phoneNumber,
      'department': department,
      'role': role,
      'status': status,
      'password': password,
      if (image.isNotEmpty) 'image': image,
      'dependants': dependants.map((dep) => dep.toMap()).toList(),
      'annual': annual,
      'sick': sick,
      'maternity': maternity,
      'paternity': paternity,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      emp_no: json['emp_no']?.toString() ?? "",
      firstName: json['firstname'] ?? "",
      secondName: json['secondname'] ?? "",
      email: json['email'] ?? "",
      phoneNumber: json['phonenumber']?.toString() ?? "",
      department: json['department'] ?? "",
      role: json['role'] ?? "user",
      image: json['image'] ?? "",
      status: json['status'] ?? "",
      password: "", // Do not populate passwords from backend for security
      dependants: _parseDependants(json['dependant']),

      annual: _parseInt(json['annual']),
      sick: _parseInt(json['sick']),
      maternity: _parseInt(json['maternity']),
      paternity: _parseInt(json['paternity']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null || value == "") return null;
    return int.tryParse(value.toString());
  }

  static List<Dependant> _parseDependants(dynamic value) {
    if (value == null || value is! List) return [];
    return value
        .map((dep) => Dependant.fromJson(dep))
        .toList()
        .cast<Dependant>();
  }
}
