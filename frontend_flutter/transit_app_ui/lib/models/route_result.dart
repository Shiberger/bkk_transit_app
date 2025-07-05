import 'route_step.dart';

class RouteResult {
  final int totalTime;
  final int totalStations;
  final int estimatedFare;
  final List<RouteStep> steps;

  RouteResult({
    required this.totalTime,
    required this.totalStations,
    required this.estimatedFare,
    required this.steps,
  });

  factory RouteResult.fromJson(Map<String, dynamic> json) {
    var stepsList = json['steps'] as List;
    List<RouteStep> steps = stepsList.map((i) => RouteStep.fromJson(i)).toList();

    return RouteResult(
      totalTime: json['total_time'],
      totalStations: json['total_stations'],
      estimatedFare: json['estimated_fare'] ?? 0,
      steps: steps,
    );
  }
}