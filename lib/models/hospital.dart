import 'package:latlong2/latlong.dart';

class Hospital {
  final String name;
  final LatLng location;
  
  // Dibuat tidak final dan nullable karena nilainya diisi setelah objek dibuat
  double? distanceInKm;

  Hospital({
    required this.name,
    required this.location,
    this.distanceInKm,
  });
}