import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:rescuein/models/hospital.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';

class HospitalNearbyPage extends StatefulWidget {
  const HospitalNearbyPage({super.key});

  @override
  State<HospitalNearbyPage> createState() => _HospitalNearbyPageState();
}

class _HospitalNearbyPageState extends State<HospitalNearbyPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  
  bool _isLoading = true;
  String _loadingMessage = "Memeriksa izin lokasi...";
  Position? _currentPosition;
  List<Hospital> _hospitals = [];
  Hospital? _selectedHospital;
  
  final LatLng _defaultLocation = const LatLng(-7.7956, 110.3695);

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
  
  Future<void> _initializeScreen() async {
    bool hasPermission = await _handleLocationPermission();
    if (hasPermission) {
      _listenToLocationUpdates();
    } else {
      setState(() => _loadingMessage = "Mencari rumah sakit terdekat...");
      await _fetchAndProcessHospitals(_defaultLocation);
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layanan lokasi tidak aktif. Mohon aktifkan GPS.')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak permanen, kami tidak bisa meminta izin lagi.')));
      return false;
    } 

    return true;
  }

  void _listenToLocationUpdates() {
    setState(() => _loadingMessage = "Mendapatkan lokasi Anda...");
    
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) async {
        bool isFirstUpdate = _currentPosition == null;
        setState(() => _currentPosition = position);
        
        if (isFirstUpdate) {
          _mapController.move(LatLng(position.latitude, position.longitude), 14.0);
          setState(() => _loadingMessage = "Mencari rumah sakit terdekat...");
          await _fetchAndProcessHospitals(LatLng(position.latitude, position.longitude));
        } else {
          // Untuk update selanjutnya, cukup hitung ulang jarak
          _updateDistancesAndSort();
          setState(() {}); // Panggil setState untuk refresh UI list
        }
      }
    );
  }
  
  Future<void> _fetchAndProcessHospitals(LatLng location) async {
    await _fetchNearbyHospitals(location);
    _updateDistancesAndSort();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNearbyHospitals(LatLng location) async {
    String query = """
      [out:json];
      (
        node["amenity"="hospital"](around:5000,${location.latitude},${location.longitude});
        way["amenity"="hospital"](around:5000,${location.latitude},${location.longitude});
      );
      out center;
    """;

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'), body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'];
        _hospitals = elements.map((e) {
          String name = e['tags']?['name'] ?? 'Rumah Sakit Tanpa Nama';
          double lat = e['lat'] ?? e['center']['lat'];
          double lon = e['lon'] ?? e['center']['lon'];
          return Hospital(name: name, location: LatLng(lat, lon));
        }).toList();
      }
    } catch (e) {
      print("Error fetching hospitals: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat data rumah sakit.')));
    }
  }

  void _updateDistancesAndSort() {
    if (_currentPosition == null) return;

    for (var hospital in _hospitals) {
      hospital.distanceInKm = Geolocator.distanceBetween(
        _currentPosition!.latitude, _currentPosition!.longitude,
        hospital.location.latitude, hospital.location.longitude,
      ) / 1000;
    }

    _hospitals.sort((a, b) => a.distanceInKm!.compareTo(b.distanceInKm!));
    if (_hospitals.isNotEmpty && _selectedHospital == null) {
      _selectedHospital = _hospitals.first;
    }
  }
  
  Future<void> _launchNavigation(LatLng destination) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka aplikasi peta.')));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rumah Sakit Terdekat"),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
      ),
      body: Stack(
        children: [
          _buildMap(),
          if (_hospitals.isNotEmpty) _buildHospitalListSheet(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 14.0);
          }
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.my_location, color: whiteColor),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition != null 
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : _defaultLocation,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rescuein.app',
        ),
        MarkerLayer(
          markers: _hospitals.map((hospital) {
            bool isSelected = hospital == _selectedHospital;
            return Marker(
              width: 150,
              height: 100,
              point: hospital.location,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedHospital = hospital);
                  _mapController.move(hospital.location, 15.0);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))]
                      ),
                      child: Text(
                        hospital.name, 
                        style: bodySmallTextStyle.copyWith(fontWeight: FontWeight.bold, color: textPrimaryColor),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Icon(
                      Icons.location_on, 
                      color: isSelected ? Colors.blue.shade700 : Colors.red.shade700, 
                      size: 40
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        // --- PENAMBAHAN BAGIAN INI ---
        // Layer khusus untuk menampilkan posisi pengguna
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Container(
                       decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade800,
                          border: Border.all(color: Colors.white, width: 2)
                       ),
                    ),
                  ),
                ),
                width: 20,
                height: 20,
              )
            ],
          )
      ],
    );
  }

  Widget _buildHospitalListSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [strongShadow],
          ),
          child: ListView.separated(
            controller: scrollController,
            itemCount: _hospitals.length,
            separatorBuilder: (context, index) => Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final hospital = _hospitals[index];
              final isClosest = index == 0;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isClosest ? accentColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                  child: Icon(Icons.local_hospital_outlined, color: isClosest ? accentColor : primaryColor),
                ),
                title: Text(hospital.name, style: modernBlackTextStyle.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Jarak: ${hospital.distanceInKm?.toStringAsFixed(2) ?? '-'} km',
                  style: bodyMediumTextStyle.copyWith(color: textSecondaryColor),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.directions, color: primaryColor),
                  onPressed: () => _launchNavigation(hospital.location),
                  tooltip: 'Mulai Navigasi',
                ),
                onTap: () {
                  setState(() => _selectedHospital = hospital);
                  _mapController.move(hospital.location, 15.0);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 20),
            Text(_loadingMessage, style: modernWhiteTextStyle),
          ],
        ),
      ),
    );
  }
}