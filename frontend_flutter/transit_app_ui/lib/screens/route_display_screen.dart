import 'package:flutter/material.dart';
import '../models/route_result.dart';
import '../models/route_step.dart';

class RouteDisplayScreen extends StatelessWidget {
  final RouteResult routeResult;

  const RouteDisplayScreen({super.key, required this.routeResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Route'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn(Icons.timer_outlined, '${routeResult.totalTime} min', 'Total Time'),
                    _buildInfoColumn(Icons.pin_drop_outlined, '${routeResult.totalStations} stops', 'Stations'),
                    _buildInfoColumn(Icons.transfer_within_a_station, '${routeResult.steps.where((s) => s.type == 'transfer').length}', 'Transfers'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: routeResult.steps.length,
              itemBuilder: (context, index) {
                final step = routeResult.steps[index];
                return _buildStepCard(step);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.teal, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStepCard(RouteStep step) {
    if (step.type == 'board') {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Icon(Icons.train, color: step.lineColor, size: 40),
          title: Text(step.lineName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('From ${step.startStation} to ${step.endStation}\n${step.stops} stops'),
          isThreeLine: true,
        ),
      );
    } else { // transfer
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.transfer_within_a_station, color: Colors.orange, size: 40),
          title: const Text('Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('From ${step.fromStation} to ${step.toStation}'),
        ),
      );
    }
  }
}