import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// --- PLACEHOLDER MODELS & THEME ---
class HealthFacility {
  final String name;
  final String type;
  final LatLng location;
  double? distanceInKm;

  HealthFacility({
    required this.name,
    required this.type,
    required this.location,
    this.distanceInKm,
  });
}

const Color primaryColor = Colors.blue;
const Color accentColor = Colors.cyan;
const Color pharmacyColor = Colors.green;
const Color whiteColor = Colors.white;
const Color textPrimaryColor = Colors.black87;
const Color textSecondaryColor = Colors.black54;
const Color cardColor = Colors.white;
const TextStyle heading5TextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimaryColor);
const TextStyle bodyMediumTextStyle = TextStyle(fontSize: 14, color: textPrimaryColor);
const TextStyle bodySmallTextStyle = TextStyle(fontSize: 12, color: textPrimaryColor);
const TextStyle modernWhiteTextStyle = TextStyle(fontSize: 16, color: Colors.white);
final BoxShadow strongShadow = BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4));

class RouteStep {
  final String instruction;
  final double distance;
  final LatLng startLocation;
  RouteStep({required this.instruction, required this.distance, required this.startLocation});
}
// --- END OF PLACEHOLDERS ---


class HospitalNearbyPage extends StatefulWidget {
  const HospitalNearbyPage({super.key});

  @override
  State<HospitalNearbyPage> createState() => _HospitalNearbyPageState();
}

class _HospitalNearbyPageState extends State<HospitalNearbyPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final String _orsApiKey = dotenv.env['OPENROUTESERVICE_API_KEY'] ?? 'API_KEY_NOT_FOUND';
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;

  bool _isLoading = true;
  String _loadingMessage = "Memeriksa izin lokasi...";
  Position? _currentPosition;
  List<HealthFacility> _facilities = [];
  HealthFacility? _selectedFacility;
  final LatLng _defaultLocation = const LatLng(-7.7956, 110.3695); // Yogyakarta

  bool _isNavigating = false;
  List<LatLng> _routePoints = [];
  List<RouteStep> _routeSteps = [];
  int _currentStepIndex = 0;
  String _totalRouteDistance = "";
  String _totalRouteDuration = "";
  double _distanceToNextStep = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    // PERBAIKAN KRUSIAL: Membatalkan stream saat widget dihancurkan
    // untuk menghentikan semua listener dan mencegah error setState.
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    bool hasPermission = await _handleLocationPermission();
    if (!mounted) return;

    if (hasPermission) {
      _listenToLocationUpdates();
    } else {
      setState(() => _loadingMessage = "Mencari fasilitas terdekat (mode default)...");
      await _fetchAndProcessFacilities(_defaultLocation);
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layanan lokasi tidak aktif. Mohon aktifkan GPS.')));
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!mounted) return false;
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak permanen, kami tidak bisa meminta izin.')));
      return false;
    }
    return true;
  }

  void _listenToLocationUpdates() {
    if (!mounted) return;
    setState(() => _loadingMessage = "Mendapatkan lokasi Anda...");

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update setiap 10 meter untuk efisiensi
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      if (!mounted) return;

      final bool isFirstUpdate = _currentPosition == null;
      _currentPosition = position;

      if (isFirstUpdate) {
        setState(() => _loadingMessage = "Mencari fasilitas terdekat...");
        _mapController.move(LatLng(position.latitude, position.longitude), 14.0);
        await _fetchAndProcessFacilities(LatLng(position.latitude, position.longitude));
      } else {
        if (!mounted) return;
        _updateDistancesAndSort();
        if (_isNavigating) {
          _updateNavigationState(position);
        }
        setState(() {});
      }
    });
  }

  Future<void> _fetchAndProcessFacilities(LatLng location) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await _fetchNearbyFacilities(location);
    if (!mounted) return;

    _updateDistancesAndSort();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchNearbyFacilities(LatLng location) async {
    // IMPLEMENTASI: Query diperbarui untuk mencari hospital, clinic, dan pharmacy
    final query = """
      [out:json];
      (
        node["amenity"~"hospital|clinic|pharmacy"](around:5000,${location.latitude},${location.longitude});
        way["amenity"~"hospital|clinic|pharmacy"](around:5000,${location.latitude},${location.longitude});
      );
      out center;
    """;
    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': query},
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'];
        _facilities = elements.map((e) {
          String type = e['tags']?['amenity'] ?? 'unknown';
          String name = e['tags']?['name'] ?? 'Fasilitas Tanpa Nama';
          double lat = e['lat'] ?? e['center']['lat'];
          double lon = e['lon'] ?? e['center']['lon'];
          return HealthFacility(name: name, type: type, location: LatLng(lat, lon));
        }).toList();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat data fasilitas kesehatan.')));
    }
  }

  void _updateDistancesAndSort() {
    if (_currentPosition == null || !mounted) return;

    for (var facility in _facilities) {
      facility.distanceInKm = Geolocator.distanceBetween(
            _currentPosition!.latitude, _currentPosition!.longitude,
            facility.location.latitude, facility.location.longitude) / 1000;
    }
    _facilities.sort((a, b) => a.distanceInKm!.compareTo(b.distanceInKm!));
    if (_facilities.isNotEmpty && _selectedFacility == null) {
      _selectedFacility = _facilities.first;
    }
  }

  void _updateNavigationState(Position position) {
    if (!mounted || _routeSteps.isEmpty) return;
    final userLocation = LatLng(position.latitude, position.longitude);

    if (_currentStepIndex < _routeSteps.length - 1) {
      final nextStep = _routeSteps[_currentStepIndex + 1];
      final distanceToNextManeuver = Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, nextStep.startLocation.latitude, nextStep.startLocation.longitude);
      if (distanceToNextManeuver < 20) {
        setState(() => _currentStepIndex++);
      }
      setState(() => _distanceToNextStep = distanceToNextManeuver);
    } else {
      setState(() => _distanceToNextStep = 0);
    }
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentPosition == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lokasi saat ini tidak ditemukan.")));
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingMessage = "Membuat rute navigasi...";
    });

    final start = _currentPosition!;
    final url = 'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$_orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}';
    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'][0];
        final geometry = features['geometry']['coordinates'] as List;
        final points = geometry.map((p) => LatLng(p[1], p[0])).toList();
        final properties = features['properties']['summary'];
        final segments = features['properties']['segments'][0];
        final stepsData = segments['steps'] as List;

        final List<RouteStep> steps = stepsData.map((step) {
          final wayPoints = step['way_points'] as List;
          final startPointIndex = wayPoints[0];
          final startCoord = geometry[startPointIndex];
          return RouteStep(instruction: step['instruction'], distance: (step['distance'] as num).toDouble(), startLocation: LatLng(startCoord[1], startCoord[0]));
        }).toList();

        setState(() {
          _routePoints = points;
          _routeSteps = steps;
          _currentStepIndex = 0;
          _totalRouteDistance = "${((properties['distance'] as num) / 1000).toStringAsFixed(2)} km";
          _totalRouteDuration = "${((properties['duration'] as num) / 60).ceil()} menit";
          _isNavigating = true;
        });
      } else {
        throw Exception('Gagal memuat rute');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendapatkan rute: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _stopNavigation() {
    if (!mounted) return;
    setState(() {
      _isNavigating = false;
      _routePoints = [];
      _routeSteps = [];
      _currentStepIndex = 0;
    });
    if (_currentPosition != null) {
      _mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNavigating ? "Mode Navigasi" : "Fasilitas Kesehatan Terdekat"),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        leading: _isNavigating ? IconButton(icon: const Icon(Icons.close), onPressed: _stopNavigation, tooltip: "Hentikan Navigasi") : null,
      ),
      body: Stack(
        children: [
          _buildMap(),
          if (!_isNavigating && _facilities.isNotEmpty) _buildFacilityListSheet(),
          if (_isNavigating) _buildNavigationUI(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: _isNavigating ? null : FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 14.0);
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.my_location, color: whiteColor),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition != null ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude) : _defaultLocation,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.rescuein.app', // Ganti dengan package name Anda
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(polylines: [ Polyline(points: _routePoints, strokeWidth: 5, color: Colors.blue.shade700) ]),
        if (!_isNavigating)
          MarkerLayer(
            markers: _facilities.map((facility) {
              bool isSelected = facility == _selectedFacility;
              IconData iconData;
              Color iconColor;
              switch (facility.type) {
                case 'hospital':
                  iconData = Icons.local_hospital;
                  iconColor = isSelected ? Colors.red.shade700 : Colors.red.shade400;
                  break;
                case 'clinic':
                  iconData = Icons.medical_services;
                  iconColor = isSelected ? Colors.orange.shade700 : Colors.orange.shade400;
                  break;
                case 'pharmacy':
                  iconData = Icons.local_pharmacy;
                  iconColor = isSelected ? pharmacyColor : Colors.grey;
                  break;
                default:
                  iconData = Icons.location_on;
                  iconColor = Colors.grey;
              }
              return Marker(
                width: 150, height: 100, point: facility.location,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedFacility = facility);
                    _mapController.move(facility.location, 15.0);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))]),
                        child: Text(facility.name, style: bodySmallTextStyle.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2),
                      ),
                      Icon(iconData, color: iconColor, size: 40),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(radius: 6, backgroundColor: Colors.blue.shade800),
                  ),
                ),
                width: 20, height: 20,
              )
            ],
          )
      ],
    );
  }

  Widget _buildFacilityListSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3, minChildSize: 0.1, maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [strongShadow]),
          child: ListView.separated(
            controller: scrollController, itemCount: _facilities.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final facility = _facilities[index];
              IconData iconData;
              Color iconColor;
              String typeName = "Lainnya";
              switch (facility.type) {
                case 'hospital':
                  iconData = Icons.local_hospital_outlined;
                  iconColor = primaryColor;
                  typeName = "Rumah Sakit";
                  break;
                case 'clinic':
                  iconData = Icons.medical_services_outlined;
                  iconColor = Colors.orange;
                  typeName = "Klinik / Puskesmas";
                  break;
                case 'pharmacy':
                  iconData = Icons.local_pharmacy_outlined;
                  iconColor = pharmacyColor;
                  typeName = "Apotek";
                  break;
                default:
                  iconData = Icons.pin_drop_outlined;
                  iconColor = Colors.grey;
              }
              return ListTile(
                leading: CircleAvatar(backgroundColor: iconColor.withOpacity(0.1), child: Icon(iconData, color: iconColor)),
                title: Text(facility.name, style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('$typeName • Jarak: ${facility.distanceInKm?.toStringAsFixed(2) ?? '-'} km', style: bodySmallTextStyle.copyWith(color: textSecondaryColor)),
                trailing: facility.type == 'pharmacy' ? null : IconButton(icon: Icon(Icons.directions, color: primaryColor), onPressed: () => _getRoute(facility.location), tooltip: 'Mulai Navigasi'),
                onTap: () {
                  setState(() => _selectedFacility = facility);
                  _mapController.move(facility.location, 15.0);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNavigationUI() {
    if (_routeSteps.isEmpty) return const SizedBox.shrink();
    return Positioned.fill(child: Column(children: [ _buildNavigationInstructionCard(), const Spacer(), _buildNavigationInfoFooter() ]));
  }

  Widget _buildNavigationInstructionCard() {
    final currentStep = _routeSteps[_currentStepIndex];
    String distanceText = _currentStepIndex < _routeSteps.length - 1 ? 'Dalam ${_distanceToNextStep.toStringAsFixed(0)} m' : 'Anda akan segera tiba';
    return Card(
      margin: const EdgeInsets.all(8), elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(children: [
          const Icon(Icons.navigation, size: 40, color: primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(distanceText, style: bodyMediumTextStyle.copyWith(color: textSecondaryColor)),
              Text(currentStep.instruction, style: heading5TextStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          )
        ]),
      ),
    );
  }

  Widget _buildNavigationInfoFooter() {
    return Card(
      margin: const EdgeInsets.all(0), elevation: 10,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text("ESTIMASI TIBA", style: bodySmallTextStyle.copyWith(color: textSecondaryColor)),
            const SizedBox(height: 4),
            Text(_totalRouteDuration, style: heading5TextStyle),
          ]),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text("SISA JARAK", style: bodySmallTextStyle.copyWith(color: textSecondaryColor)),
            const SizedBox(height: 4),
            Text(_totalRouteDistance, style: heading5TextStyle),
          ]),
        ]),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 20),
          Text(_loadingMessage, style: modernWhiteTextStyle),
        ]),
      ),
    );
  }
}