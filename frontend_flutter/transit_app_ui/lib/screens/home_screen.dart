import 'package:flutter/material.dart';
import '../models/route_result.dart';
import '../models/station.dart';
import '../services/api_service.dart';
import 'route_display_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Station> _stations = [];
  Station? _startStation;
  Station? _destinationStation;
  bool _isLoading = true;
  bool _isFindingRoute = false;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    try {
      List<Station> stations = await _apiService.getStations();
      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      _showError('Failed to load stations: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _findRoute() async {
    if (_startStation == null || _destinationStation == null) {
      _showError('Please select both a start and destination station.');
      return;
    }

    if (_startStation!.id == _destinationStation!.id) {
      _showError('Start and destination cannot be the same.');
      return;
    }

    setState(() { _isFindingRoute = true; });

    try {
      final result = await _apiService.findRoute(_startStation!.id, _destinationStation!.id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RouteDisplayScreen(routeResult: result)),
      );
    } catch(e) {
      _showError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setState(() { _isFindingRoute = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BKK Transit Route Finder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Station>(
                    value: _startStation,
                    hint: const Text('Select Start Station'),
                    isExpanded: true,
                    items: _stations.map((Station station) {
                      return DropdownMenuItem<Station>(
                        value: station,
                        child: Text(station.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (Station? newValue) {
                      setState(() { _startStation = newValue; });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Station>(
                    value: _destinationStation,
                    hint: const Text('Select Destination Station'),
                    isExpanded: true,
                    items: _stations.map((Station station) {
                      return DropdownMenuItem<Station>(
                        value: station,
                        child: Text(station.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (Station? newValue) {
                      setState(() { _destinationStation = newValue; });
                    },
                  ),
                  const Spacer(),
                  if (_isFindingRoute)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _findRoute,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Find Route'),
                    ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}