import 'route_step.dart';

class RouteResult {
  final int totalTime;
  final int totalStations;
  final List<RouteStep> steps;

  RouteResult({
    required this.totalTime,
    required this.totalStations,
    required this.steps,
  });

  factory RouteResult.fromJson(Map<String, dynamic> json) {
    var stepsList = json['steps'] as List;
    List<RouteStep> steps = stepsList.map((i) => RouteStep.fromJson(i)).toList();

    return RouteResult(
      totalTime: json['total_time'],
      totalStations: json['total_stations'],
      steps: steps,
    );
  }
}