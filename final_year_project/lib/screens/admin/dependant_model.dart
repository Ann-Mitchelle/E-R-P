class Dependant {
  final int id;
  final String name;
  final String phoneNumber;
  final String relation;

  Dependant({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relation,
  });

  // ✅ Add this method to fix the copyWith error
  Dependant copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? relation,
  }) {
    return Dependant(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relation: relation ?? this.relation,
    );
  }

  // Convert to JSON format
  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(), // Convert to string if needed
      'name': name,
      'phonenumber': phoneNumber,
      'relation': relation,
    };
  }

  // Convert JSON to Dependant object
  factory Dependant.fromJson(Map<String, dynamic> json) {
    return Dependant(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? "",
      phoneNumber: json['phonenumber'] ?? "",
      relation: json['relation'] ?? "",
    );
  }
}
