class Station {
  final String id;
  final String name;

  Station({required this.id, required this.name});

  // Factory constructor to create a Station from JSON
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
    );
  }
}