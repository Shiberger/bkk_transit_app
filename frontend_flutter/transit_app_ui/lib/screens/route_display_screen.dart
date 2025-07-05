import 'package:flutter/material.dart';
import '../models/route_result.dart';
import '../models/route_step.dart';
import '../services/favorites_service.dart'; // Import the new service

class RouteDisplayScreen extends StatefulWidget {
  final RouteResult routeResult;
  // We need the original station IDs to save the favorite route accurately
  final String startStationId;
  final String endStationId;

  const RouteDisplayScreen({
    super.key,
    required this.routeResult,
    required this.startStationId,
    required this.endStationId,
  });

  @override
  State<RouteDisplayScreen> createState() => _RouteDisplayScreenState();
}

class _RouteDisplayScreenState extends State<RouteDisplayScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  // Check if this route is already in the user's favorites
  void _checkIfFavorited() async {
    final favorites = await _favoritesService.getFavorites();
    if (mounted) {
      setState(() {
        _isFavorited = favorites.any((fav) =>
            fav.startStationId == widget.startStationId &&
            fav.endStationId == widget.endStationId);
      });
    }
  }

  // Toggle the favorite status (save or remove)
  void _toggleFavorite() async {
    final routeToSave = FavoriteRoute(
      startStationId: widget.startStationId,
      startStationName: widget.routeResult.steps.first.startStation,
      endStationId: widget.endStationId,
      endStationName: widget.routeResult.steps.last.endStation,
    );

    if (_isFavorited) {
      await _favoritesService.removeFavorite(routeToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route removed from favorites.')),
        );
      }
    } else {
      await _favoritesService.addFavorite(routeToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route saved to favorites!')),
        );
      }
    }
    // Update the UI to reflect the change
    _checkIfFavorited();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Route'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // The "favorite" button in the AppBar
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : null,
            ),
            tooltip: 'Save Route',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          // The Route Diagram section
          SizedBox(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // The diagram widget you created
              child: RouteDiagram(steps: widget.routeResult.steps),
            ),
          ),
          // The summary info card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn(Icons.timer_outlined,
                        '${widget.routeResult.totalTime} min', 'Total Time'),
                    _buildInfoColumn(Icons.pin_drop_outlined,
                        '${widget.routeResult.totalStations} stops', 'Stations'),
                    _buildInfoColumn(Icons.transfer_within_a_station,
                        '${widget.routeResult.steps.where((s) => s.type == 'transfer').length}', 'Transfers'),
                    // Displaying the estimated fare
                    _buildInfoColumn(Icons.attach_money,
                        '฿${widget.routeResult.estimatedFare}', 'Est. Fare'),
                  ],
                ),
              ),
            ),
          ),
          // The list of route steps
          Expanded(
            child: ListView.builder(
              itemCount: widget.routeResult.steps.length,
              itemBuilder: (context, index) {
                final step = widget.routeResult.steps[index];
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
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          title: Text(step.lineName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          // Added a check for operating hours to avoid showing an empty line
          subtitle: Text(
              'From ${step.startStation} to ${step.endStation}\n${step.stops} stops'
              '${step.operatingHours.isNotEmpty ? '\nHours: ${step.operatingHours}' : ''}'),
          isThreeLine: true,
        ),
      );
    } else {
      // transfer
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.transfer_within_a_station,
              color: Colors.orange, size: 40),
          title: const Text('Transfer',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('From ${step.fromStation} to ${step.toStation}'),
        ),
      );
    }
  }
}

// The Route Diagram Widget
class RouteDiagram extends StatelessWidget {
  final List<RouteStep> steps;
  const RouteDiagram({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: RouteDiagramPainter(steps: steps),
    );
  }
}

// The Custom Painter logic for the diagram
class RouteDiagramPainter extends CustomPainter {
  final List<RouteStep> steps;
  RouteDiagramPainter({required this.steps});

  @override
  void paint(Canvas canvas, Size size) {
    if (steps.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    double startX = 20.0;
    final y = size.height / 2;
    // Calculate segment length to ensure it doesn't overflow
    double segmentLength = (size.width - 40) / (steps.length);


    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      paint.color = step.lineColor;

      // Draw circle for the start of the step
      canvas.drawCircle(Offset(startX, y), 8, paint..style = PaintingStyle.fill);

      // Draw station name
      textPainter.text = TextSpan(
          text: step.type == 'board' ? step.startStation : step.fromStation,
          style: const TextStyle(fontSize: 12, color: Colors.black));
      textPainter.layout(minWidth: 0, maxWidth: segmentLength);
      textPainter.paint(canvas, Offset(startX - textPainter.width / 2, y + 15));
      
      // Draw the line segment
      final nextX = startX + segmentLength;
      if (step.type == 'board') {
        canvas.drawLine(Offset(startX, y), Offset(nextX, y),
            paint..style = PaintingStyle.stroke);
      } else {
        _drawDashedLine(canvas, Offset(startX, y), Offset(nextX, y),
            paint..color = Colors.orange);
      }
      startX = nextX;
    }

    // Draw the final station at the end of the line
    final lastStep = steps.last;
    paint.color = lastStep.lineColor;
    canvas.drawCircle(Offset(startX, y), 8, paint..style = PaintingStyle.fill);
    textPainter.text = TextSpan(
        text: lastStep.endStation,
        style: const TextStyle(fontSize: 12, color: Colors.black));
    textPainter.layout();
    textPainter.paint(canvas, Offset(startX - textPainter.width / 2, y + 15));
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 5.0;
    const double dashSpace = 3.0;
    final path = Path();
    double startX = p1.dx;
    while (startX < p2.dx) {
      path.moveTo(startX, p1.dy);
      path.lineTo(startX + dashWidth, p1.dy);
      startX += dashWidth + dashSpace;
    }
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}