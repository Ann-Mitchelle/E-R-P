class User {
  String? id; // Optional, assigned by backend
  String firstName;
  String secondName;
  String email;
  String phoneNumber;
  String department;
  String role;
  String image; // Image URL from backend
  String status;
  String password;

  User({
    this.id, // Optional
    required this.firstName,
    required this.secondName,
    required this.email,
    required this.phoneNumber,
    required this.department,
    required this.role,
    required this.image,
    required this.status,
    required this.password,
  });

  // Convert User object to Map (Include image if available)
  Map<String, dynamic> toMap() {
    return {
      'firstname': firstName,
      'secondname': secondName,
      'email': email,
      'phonenumber': phoneNumber,
      'department': department,
      'role': role,
      'status': status,
      'password': password, // ⚠️ Consider removing if not sending raw passwords
      if (image.isNotEmpty)
        'image': image, // Include only if image is not empty
    };
  }

  // Convert JSON response from backend to a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? "", // Ensure it's a string
      firstName: json['firstname'] ?? "",
      secondName: json['secondname'] ?? "",
      email: json['email'] ?? "",
      phoneNumber:
          json['phonenumber']?.toString() ?? "", // Ensure it's a string
      department: json['department'] ?? "",
      role: json['role'] ?? "user",
      image: json['image'] ?? "", // Ensure no null errors
      status: json['status'] ?? "",
      password:
          "", // ⚠️ Do not store passwords in frontend objects for security
    );
  }
}
