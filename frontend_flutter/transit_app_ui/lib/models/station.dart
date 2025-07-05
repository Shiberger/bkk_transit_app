class Station {
  final String id;
  final String name;
  // Add position, but make it optional as we only need it for the diagram
  final Map<String, double>? position; 

  Station({required this.id, required this.name, this.position});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      // Parse the position if it exists
      position: json['position'] != null ? Map<String, double>.from(json['position']) : null,
    );
  }
}