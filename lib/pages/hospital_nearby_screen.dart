// lib/pages/hospital_nearby_screen.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../models/hospital.dart';

// --- STYLING ---
const Color primaryColor = Color(0xFF4A90E2);
const Color hospitalColor = Color(0xFFD0021B);
const Color clinicColor = Color(0xFFF5A623);
const Color pharmacyColor = Color(0xFF4CAF50);
const Color whiteColor = Colors.white;
const Color textPrimaryColor = Colors.black87;
const Color textSecondaryColor = Colors.black54;
const Color cardColor = Colors.white;
const TextStyle bodyMediumTextStyle = TextStyle(fontSize: 14, color: textPrimaryColor);
const TextStyle bodySmallTextStyle = TextStyle(fontSize: 12, color: textPrimaryColor);
final BoxShadow strongShadow = BoxShadow(
  color: Colors.black26,
  blurRadius: 8,
  offset: Offset(0, 4),
);
// --- END OF STYLING ---

class HospitalNearbyPage extends StatefulWidget {
  const HospitalNearbyPage({super.key});

  @override
  State<HospitalNearbyPage> createState() => _HospitalNearbyPageState();
}

class _HospitalNearbyPageState extends State<HospitalNearbyPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  MapboxMap? _mapboxMapController;

  // Managers for POIs
  PointAnnotationManager? _facilityManager; // all facilities markers
  PolylineAnnotationManager? _polylineManager; // route polyline
  PointAnnotationManager? _userMarkerManager; // user marker
  PointAnnotationManager? _destinationManager; // destination marker

  // Streams / cancelables
  StreamSubscription<geo.Position>? _positionStream;
  Cancelable? _facilityTapCancelable;

  // Assets
  Uint8List? _facilityIconBytes; // generic marker (fallback)
  Uint8List? _userIconBytes;     // user marker icon
  Uint8List? _destIconBytes;     // destination marker icon

  bool _isLoading = true;
  String _loadingMessage = "Memeriksa izin lokasi...";
  geo.Position? _currentPosition;

  List<Hospital> _allFacilities = [];
  List<Hospital> _filteredFacilities = [];
  Hospital? _selectedFacility;
  FacilityType _activeFilter = FacilityType.unknown; // unknown = Semua

  final LatLng _defaultLocation = const LatLng(-7.7956, 110.3695); // Yogyakarta

  // Mapbox token (non-null, assert loaded in main)
  String get _mapboxToken => dotenv.env['MAPBOX_ACCESS_TOKEN']!;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _loadMarkerAssets();
  }

  Future<void> _loadMarkerAssets() async {
    // Load 3 optional icons; fall back to default if not found
    Future<Uint8List?> load(String path) async {
      try {
        final ByteData bytes = await rootBundle.load(path);
        return bytes.buffer.asUint8List();
      } catch (_) {
        if (kDebugMode) debugPrint('Asset not found: $path (using default icon)');
        return null;
      }
    }

    final facility = await load('assets/marker_icon (1).png');
    final user = await load('');
    final dest = await load('assets/destination_marker (3) (1).png');

    if (!mounted) return;
    setState(() {
      _facilityIconBytes = facility;
      _userIconBytes = user;
      _destIconBytes = dest;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _facilityTapCancelable?.cancel();

    // Clean up annotations
    unawaited(_polylineManager?.deleteAll());
    unawaited(_facilityManager?.deleteAll());
    unawaited(_userMarkerManager?.deleteAll());
    unawaited(_destinationManager?.deleteAll());

    super.dispose();
  }

  // onMapCreated untuk MapWidget (mapbox_maps_flutter)
  Future<void> _onMapCreated(MapboxMap controller) async {
    _mapboxMapController = controller;

    // NOTE: gestures are enabled by default in mapbox_maps_flutter.
    // If you need to tweak gesture settings, ensure your sdk version supports the
    // Gestures API; otherwise remove/update this block. To keep compatibility we
    // omit calling a GestureSettings constructor here which may not exist on some
    // versions of the package.

    // Create managers
    _facilityManager =
        await _mapboxMapController!.annotations.createPointAnnotationManager();
    _polylineManager =
        await _mapboxMapController!.annotations.createPolylineAnnotationManager();
    _userMarkerManager =
        await _mapboxMapController!.annotations.createPointAnnotationManager();
    _destinationManager =
        await _mapboxMapController!.annotations.createPointAnnotationManager();

    // Handle taps on facility markers
    _facilityTapCancelable = _facilityManager!.tapEvents(
      onTap: (annotation) {
        final coords = annotation.geometry.coordinates;
        final tapped = LatLng(coords[1]!.toDouble(), coords[0]!.toDouble());
        final tappedFacility = _filteredFacilities.isEmpty
            ? null
            : _filteredFacilities.firstWhere(
                (f) =>
                    (f.location.latitude - tapped.latitude).abs() < 0.0001 &&
                    (f.location.longitude - tapped.longitude).abs() < 0.0001,
                orElse: () => _filteredFacilities.first,
              );
        if (tappedFacility != null) {
          _onFacilitySelected(tappedFacility);
        }
      },
    );

    // If we already have data, render them
    unawaited(_updateFacilityAnnotations());
  }

  void _onFacilitySelected(Hospital facility) async {
    setState(() => _selectedFacility = facility);

    // Fly to destination
    await _mapboxMapController?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(facility.location.longitude, facility.location.latitude)),
        zoom: 16.5,
      ),
      MapAnimationOptions(duration: 900, startDelay: 0),
    );

    // Add/Update destination marker explicitly
    await _addOrUpdateDestinationMarker(
      Point(coordinates: Position(facility.location.longitude, facility.location.latitude)),
    );
  }

  Future<void> _initializeScreen() async {
    assert(dotenv.env['MAPBOX_ACCESS_TOKEN'] != null, 'MAPBOX_ACCESS_TOKEN must be set in .env');

    final hasPermission = await _handleLocationPermission();
    if (!mounted) return;

    if (hasPermission) {
      _listenToLocationUpdates();
    } else {
      setState(() => _loadingMessage = "Mencari fasilitas terdekat (mode default)...");
      await _fetchAndProcessFacilities(_defaultLocation);
    }
  }

  Future<bool> _handleLocationPermission() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan lokasi tidak aktif. Mohon aktifkan GPS.')),
      );
      return false;
    }

    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        return false;
      }
    }

    if (permission == geo.LocationPermission.deniedForever && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Izin lokasi ditolak permanen, kami tidak bisa meminta izin.'),
      ));
      return false;
    }
    return true;
  }

  void _listenToLocationUpdates() {
    if (!mounted) return;
    setState(() => _loadingMessage = "Mendapatkan lokasi Anda...");

    const geo.LocationSettings locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    _positionStream = geo.Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((geo.Position position) async {
      if (!mounted) return;
      final isFirstUpdate = _currentPosition == null;
      _currentPosition = position;

      final bearing = (position.heading.isNaN) ? 0.0 : position.heading;

      // Add/Update user marker
      await _addOrUpdateUserMarker(
        Point(coordinates: Position(position.longitude, position.latitude)),
        bearing,
      );

      // camera follow with tilt & bearing for navigation feel
      _mapboxMapController?.easeTo(
        CameraOptions(
          center: Point(coordinates: Position(position.longitude, position.latitude)),
          zoom: 16.5,
          pitch: 60.0,
          bearing: bearing,
        ),
        MapAnimationOptions(duration: 800),
      );

      if (isFirstUpdate) {
        setState(() => _loadingMessage = "Mencari fasilitas terdekat...");
        await _fetchAndProcessFacilities(LatLng(position.latitude, position.longitude));
      } else {
        _updateDistancesAndSort();
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _addOrUpdateUserMarker(Point geometry, double bearing) async {
    if (_userMarkerManager == null) return;

    final opts = PointAnnotationOptions(
      geometry: geometry,
      iconSize: 1.6,
      image: _userIconBytes ?? _facilityIconBytes,
      iconRotate: bearing,
    );

    try {
      // Use create + update for user marker; we don't keep a field reference
      // because the manager keeps track of it. This avoids an unused-field lint.
      await _userMarkerManager!.create(opts);
      // We don't need to store `existing` in a field unless you need to update it later.
    } catch (e) {
      if (kDebugMode) debugPrint('User marker create/update error: $e');
    }
  }

  Future<void> _addOrUpdateDestinationMarker(Point geometry) async {
    if (_destinationManager == null) return;

    final opts = PointAnnotationOptions(
      geometry: geometry,
      iconSize: 1.4,
      image: _destIconBytes ?? _facilityIconBytes,
    );

    try {
      // Keep a single destination marker
      await _destinationManager!.deleteAll();
      await _destinationManager!.create(opts);
    } catch (e) {
      if (kDebugMode) debugPrint('Destination marker error: $e');
    }
  }

  Future<void> _fetchAndProcessFacilities(LatLng location) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _fetchNearbyFacilities(location);
    if (!mounted) return;
    _updateDistancesAndSort();
    _applyFilter(); // initial filter
    setState(() => _isLoading = false);
  }

  Future<void> _fetchNearbyFacilities(LatLng location) async {
    final query = '''
[out:json][timeout:25];
(
  node["amenity"~"hospital|clinic|pharmacy|doctors"](around:5000,${location.latitude},${location.longitude});
  way["amenity"~"hospital|clinic|pharmacy|doctors"](around:5000,${location.latitude},${location.longitude});
  relation["amenity"~"hospital|clinic|pharmacy|doctors"](around:5000,${location.latitude},${location.longitude});
);
out center meta;
''';

    try {
      final response = await http
          .post(
            Uri.parse('https://overpass-api.de/api/interpreter'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'data=$query',
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'] as List? ?? [];

        _allFacilities = elements.where((e) {
          return (e['lat'] != null && e['lon'] != null) ||
              (e['center'] != null &&
                  e['center']['lat'] != null &&
                  e['center']['lon'] != null);
        }).map<Hospital>((e) {
          final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? {};
          final String name = tags['name'] ?? tags['brand'] ?? tags['operator'] ?? 'Fasilitas Kesehatan';

          final double lat = (e['lat'] ?? e['center']?['lat'])?.toDouble() ?? 0.0;
          final double lon = (e['lon'] ?? e['center']?['lon'])?.toDouble() ?? 0.0;

          final String amenity = (tags['amenity'] ?? 'unknown').toString();
          final String healthcare = (tags['healthcare'] ?? '').toString();

          return Hospital(
            name: name,
            location: LatLng(lat, lon),
            type: _getFacilityType(amenity, healthcare),
          );
        }).toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching facilities: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data fasilitas kesehatan: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      _allFacilities = [];
    }
  }

  FacilityType _getFacilityType(String amenity, String healthcare) {
    switch (amenity.toLowerCase()) {
      case 'hospital':
        return FacilityType.hospital;
      case 'clinic':
      case 'doctors':
        return FacilityType.clinic;
      case 'pharmacy':
        return FacilityType.pharmacy;
      default:
        switch (healthcare.toLowerCase()) {
          case 'hospital':
            return FacilityType.hospital;
          case 'clinic':
          case 'doctor':
            return FacilityType.clinic;
          case 'pharmacy':
            return FacilityType.pharmacy;
          default:
            return FacilityType.unknown;
        }
    }
  }

  void _updateDistancesAndSort() {
    if (_currentPosition == null || !mounted) return;

    for (final facility in _allFacilities) {
      facility.distanceInKm = geo.Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            facility.location.latitude,
            facility.location.longitude,
          ) /
          1000.0;
    }
    _allFacilities.sort((a, b) =>
        (a.distanceInKm ?? double.infinity).compareTo(b.distanceInKm ?? double.infinity));
  }

  Future<void> _updateFacilityAnnotations() async {
    if (_facilityManager == null) return;

    await _facilityManager!.deleteAll();
    if (_filteredFacilities.isEmpty) return;

    final options = _filteredFacilities.map((facility) {
      return PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(facility.location.longitude, facility.location.latitude),
        ),
        iconSize: 1.0,
        image: _facilityIconBytes, // if null, Mapbox default icon used
      );
    }).toList();

    try {
      await _facilityManager!.createMulti(options);
    } catch (e) {
      if (kDebugMode) debugPrint('createMulti error: $e');
    }
  }

  void _applyFilter([FacilityType? filter]) {
    if (filter != null) {
      _activeFilter = filter;
    }

    if (!mounted) return;
    setState(() {
      if (_activeFilter == FacilityType.unknown) {
        _filteredFacilities = List.from(_allFacilities);
      } else {
        _filteredFacilities =
            _allFacilities.where((f) => f.type == _activeFilter).toList();
      }
      if (_selectedFacility != null && !_filteredFacilities.contains(_selectedFacility)) {
        _selectedFacility = null;
      }
    });

    // update markers on map
    unawaited(_updateFacilityAnnotations());
  }

  Future<void> _startNavigation(Hospital facility) async {
    if (_currentPosition == null || _mapboxMapController == null || _polylineManager == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi Anda belum tersedia')),
        );
      }
      return;
    }

    final userLat = _currentPosition!.latitude;
    final userLng = _currentPosition!.longitude;
    final destLat = facility.location.latitude;
    final destLng = facility.location.longitude;

    final tokenEncoded = Uri.encodeComponent(_mapboxToken);
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$userLng,$userLat;$destLng,$destLat?geometries=geojson&overview=full&steps=false&access_token=$tokenEncoded';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = (data['routes'][0]['geometry']['coordinates'] as List)
            .map((c) => Position((c[0] as num).toDouble(), (c[1] as num).toDouble()))
            .toList();

        // Hapus polyline lama supaya tidak double
        await _polylineManager!.deleteAll();

        // Tambah polyline baru (LineString required)
        await _polylineManager!.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: coords),
            lineColor: Colors.blue.value,
            lineWidth: 6,
          ),
        );

        // Add/Update explicit destination marker
        await _addOrUpdateDestinationMarker(
          Point(coordinates: Position(destLng, destLat)),
        );

        // Center camera to user with nav style (tilt and bearing)
        final bearing = _currentPosition?.heading ?? 0.0;
        await _mapboxMapController!.easeTo(
          CameraOptions(
            center: Point(coordinates: Position(userLng, userLat)),
            zoom: 16.5,
            pitch: 60.0,
            bearing: bearing,
          ),
          MapAnimationOptions(duration: 900),
        );

        // store selected facility for UI
        setState(() => _selectedFacility = facility);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal ambil rute: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ambil rute: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fasilitas Kesehatan Terdekat"),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              final pos = _currentPosition;
              final base = pos != null ? LatLng(pos.latitude, pos.longitude) : _defaultLocation;
              unawaited(_fetchAndProcessFacilities(base));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          Positioned(top: 10, left: 10, right: 10, child: _buildFilterChips()),
          if (_filteredFacilities.isNotEmpty) _buildFacilityListSheet(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.my_location, color: whiteColor),
        onPressed: () {
          final pos = _currentPosition;
          final target = pos != null
              ? Point(coordinates: Position(pos.longitude, pos.latitude))
              : Point(coordinates: Position(_defaultLocation.longitude, _defaultLocation.latitude));

          _mapboxMapController?.flyTo(
            CameraOptions(center: target, zoom: pos != null ? 16.0 : 15.0),
            MapAnimationOptions(duration: 1000),
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return MapWidget(
      key: const ValueKey("mapWidget"),
      onMapCreated: _onMapCreated,
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(_defaultLocation.longitude, _defaultLocation.latitude)),
        zoom: 13.0,
      ),
      styleUri: MapboxStyles.MAPBOX_STREETS,
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip("Semua", FacilityType.unknown, Icons.map),
          _buildFilterChip("Rumah Sakit", FacilityType.hospital, Icons.local_hospital),
          _buildFilterChip("Klinik", FacilityType.clinic, Icons.medical_services),
          _buildFilterChip("Apotek", FacilityType.pharmacy, Icons.local_pharmacy),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, FacilityType type, IconData icon) {
    final isSelected = _activeFilter == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        avatar: Icon(icon, color: isSelected ? Colors.white : textPrimaryColor),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) _applyFilter(type);
        },
        backgroundColor: Colors.white,
        selectedColor: primaryColor,
        labelStyle: TextStyle(color: isSelected ? Colors.white : textPrimaryColor),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildFacilityListSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [strongShadow],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (_filteredFacilities.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ditemukan ${_filteredFacilities.length} fasilitas kesehatan',
                        style: bodySmallTextStyle.copyWith(
                          color: textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _filteredFacilities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) => _buildFacilityListItem(_filteredFacilities[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFacilityListItem(Hospital facility) {
    IconData iconData;
    Color iconColor;
    String typeName;

    switch (facility.type) {
      case FacilityType.hospital:
        iconData = Icons.local_hospital;
        iconColor = hospitalColor;
        typeName = "Rumah Sakit";
        break;
      case FacilityType.clinic:
        iconData = Icons.medical_services;
        iconColor = clinicColor;
        typeName = "Klinik / Puskesmas";
        break;
      case FacilityType.pharmacy:
        iconData = Icons.local_pharmacy;
        iconColor = pharmacyColor;
        typeName = "Apotek";
        break;
      default:
        iconData = Icons.location_on;
        iconColor = Colors.grey;
        typeName = "Fasilitas Kesehatan";
    }

    final isSelected = _selectedFacility?.name == facility.name &&
        _selectedFacility?.location == facility.location;

    return Container(
      color: isSelected ? primaryColor.withAlpha(20) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withAlpha(26),
          child: Icon(iconData, color: iconColor, size: 20),
        ),
        title: Text(
          facility.name,
          style: bodyMediumTextStyle.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              typeName,
              style: bodySmallTextStyle.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (facility.distanceInKm != null)
              Text(
                '${facility.distanceInKm!.toStringAsFixed(1)} km dari lokasi Anda',
                style: bodySmallTextStyle.copyWith(color: textSecondaryColor),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (facility.type != FacilityType.pharmacy)
              IconButton(
                icon: const Icon(Icons.directions, color: primaryColor),
                onPressed: () => _startNavigation(facility),
                tooltip: 'Navigasi (in-app)',
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () => _onFacilitySelected(facility),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withAlpha(153),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [strongShadow],
              ),
              child: Text(
                _loadingMessage,
                style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
