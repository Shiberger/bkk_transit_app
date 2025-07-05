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
  
  // Use a simple string to hold the preference from the dropdown.
  // Default to 'fastest'.
  String _selectedPreference = 'fastest'; 

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
    // Check if the widget is still in the tree before showing a SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // This method now correctly calls the API and navigates to the results
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
      // Call the API with the selected stations and preference
      final RouteResult result = await _apiService.findRoute(
        _startStation!.id, 
        _destinationStation!.id,
        _selectedPreference
      );

      // Navigate to the display screen with the result
      if (mounted) {
        // *** This is the updated section ***
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDisplayScreen(
              routeResult: result,
              // We pass the IDs to the next screen so it can save the favorite
              startStationId: _startStation!.id,
              endStationId: _destinationStation!.id,
            ),
          ),
        );
      }
    } catch(e) {
      _showError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      // Ensure we stop the loading indicator even if the widget is gone
      if (mounted) {
        setState(() { _isFindingRoute = false; });
      }
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
                  // Dropdown for Start Station
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

                  // Dropdown for Destination Station
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
                  const SizedBox(height: 20),
                  
                  // Dropdown for Route Preference
                  DropdownButtonFormField<String>(
                    value: _selectedPreference,
                    decoration: const InputDecoration(
                      labelText: 'Route Preference',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'fastest',
                        child: Text('Fastest Route'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'fewest_transfers',
                        child: Text('Fewest Transfers'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() { _selectedPreference = newValue; });
                      }
                    },
                  ),

                  // Spacer pushes the button to the bottom
                  const Spacer(), 

                  // Show a loading indicator or the button
                  if (_isFindingRoute)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ))
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