class EarthquakeModel {
  final String id;
  final String place; 
  final double latitude; 
  final double longitude;
  final double mag; // level of richter
  final String depth; 
  final String time; 

  EarthquakeModel({
    required this.id,
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.mag,
    required this.depth,
    required this.time,
  });

  factory EarthquakeModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return EarthquakeModel(
      id: docId,
      place: data['place'] ?? 'Unknown Location',

      latitude: double.parse(data['latitude'] ?? '0.0'),
      longitude: double.parse(data['longitude'] ?? '0.0'),
      mag: double.parse(data['mag'] ?? '0.0'),
      depth: data['depth'] ?? '0.0',
      time: data['time'] ?? '',
    );
  }
}
