import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../model/earthquake_model.dart';
import '../service/earthquake_service.dart';

class EarthquakeDisplayScreen extends StatefulWidget {
  const EarthquakeDisplayScreen({super.key});

  @override
  State<EarthquakeDisplayScreen> createState() =>
      _EarthquakeDisplayScreenState();
}

class _EarthquakeDisplayScreenState extends State<EarthquakeDisplayScreen> {
  final EarthquakeService _mapService = EarthquakeService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";
  EarthquakeModel? _selectedEarthquake;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchEarthquake(List<EarthquakeModel> earthquakeList) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a place name to search.')),
      );
      return;
    }

    final match = earthquakeList.where((quake) {
      return quake.place.toLowerCase().contains(query);
    }).toList();

    if (match.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching earthquake location found.')),
      );
      return;
    }

    final quake = match.first;
    setState(() {
      searchQuery = quake.place;
      _selectedEarthquake = quake;
    });

    _mapController.move(LatLng(quake.latitude, quake.longitude), 6.0);
    _showEarthquakeDetails(quake);
  }

  void _showEarthquakeDetails(EarthquakeModel quake) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(quake.place),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Magnitude', quake.mag.toStringAsFixed(1)),
              _detailRow('Depth', '${quake.depth} km'),
              _detailRow('Time', quake.time),
              _detailRow(
                'Location',
                '${quake.latitude.toStringAsFixed(4)}, ${quake.longitude.toStringAsFixed(4)}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ch8: Global Earthquake Map'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<EarthquakeModel>>(
        stream: _mapService.getEarthquakeStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error while loading data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final earthquakeList = snapshot.data ?? [];
          final markers = earthquakeList.map((quake) {
            final isSelected = _selectedEarthquake?.id == quake.id;

            return Marker(
              point: LatLng(quake.latitude, quake.longitude),
              width: 50,
              height: 50,
              child: Tooltip(
                message:
                    '${quake.place}\nMagnitude: ${quake.mag.toStringAsFixed(1)}\nDepth: ${quake.depth} km',
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEarthquake = quake;
                      searchQuery = quake.place;
                      _searchController.text = quake.place;
                    });
                    _mapController.move(
                      LatLng(quake.latitude, quake.longitude),
                      6.0,
                    );
                    _showEarthquakeDetails(quake);
                  },
                  child: Icon(
                    Icons.location_on,
                    color: isSelected
                        ? Colors.blue
                        : quake.mag >= 5.0
                        ? Colors.red
                        : Colors.orange,
                    size: isSelected ? 42 : 35,
                  ),
                ),
              ),
            );
          }).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.deepPurple.withValues(alpha: 0.1),
                width: double.infinity,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  onSubmitted: (_) => _searchEarthquake(earthquakeList),
                  decoration: InputDecoration(
                    hintText: 'Search earthquake location',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchEarthquake(earthquakeList),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(-10.033, 114.2023),
                    initialZoom: 4.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
