import 'package:flutter/material.dart';

class RouteStep {
  final String type;
  final String lineName;
  final Color lineColor;
  final String startStation;
  final String endStation;
  final int stops;
  final String fromStation;
  final String toStation;
  final String operatingHours;

  RouteStep({
    required this.type,
    this.lineName = '',
    this.lineColor = Colors.grey,
    this.startStation = '',
    this.endStation = '',
    this.stops = 0,
    this.fromStation = '',
    this.toStation = '',
    this.operatingHours = '',
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    // Helper to convert hex color string to a Color object
    Color colorFromHex(String hexColor) {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF" + hexColor;
      }
      return Color(int.parse(hexColor, radix: 16));
    }

    return RouteStep(
      type: json['type'],
      lineName: json['line_name'] ?? '',
      lineColor: json['line_color'] != null ? colorFromHex(json['line_color']) : Colors.grey,
      startStation: json['start_station'] ?? '',
      endStation: json['end_station'] ?? '',
      stops: json['stops'] ?? 0,
      fromStation: json['from_station'] ?? '',
      toStation: json['to_station'] ?? '',
      operatingHours: json['operating_hours'] ?? '',
    );
  }
}