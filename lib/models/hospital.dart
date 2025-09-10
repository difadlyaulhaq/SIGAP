// lib/models/hospital.dart
import 'package:latlong2/latlong.dart';

enum FacilityType { hospital, clinic, pharmacy, unknown }

class Hospital {
  final String name;
  final LatLng location;
  final FacilityType type;
  double? distanceInKm;

  Hospital({
    required this.name,
    required this.location,
    required this.type,
    this.distanceInKm,
  });
}