import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _locationPermissionGranted = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(
      AppConstants.defaultLatitude,
      AppConstants.defaultLongitude,
    ),
    zoom: 16,
  );

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (mounted) {
      setState(() {
        _locationPermissionGranted = status.isGranted;
      });
    }
  }


  void _addMarkers() {
    for (final location in AppConstants.campusLocations) {
      _markers.add(
        Marker(
          markerId: MarkerId(location.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(location.type),
          ),
        ),
      );
    }
  }

  double _getMarkerHue(LocationType type) {
    switch (type) {
      case LocationType.building:
        return BitmapDescriptor.hueBlue;
      case LocationType.dining:
        return BitmapDescriptor.hueOrange;
      case LocationType.sports:
        return BitmapDescriptor.hueGreen;
      case LocationType.parking:
        return BitmapDescriptor.hueViolet;
      case LocationType.emergency:
        return BitmapDescriptor.hueRed;
      case LocationType.other:
        return BitmapDescriptor.hueAzure;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Campus Map'),
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                // Center on user location
              },
            ),
          ],
        ),
        body: GoogleMap(
          initialCameraPosition: _initialPosition,
          markers: _markers,
          myLocationEnabled: _locationPermissionGranted,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showLocationList,
          child: const Icon(Icons.list),
        ),
      );

  void _showLocationList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Campus Locations',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: AppConstants.campusLocations.length,
                itemBuilder: (context, index) {
                  final location = AppConstants.campusLocations[index];
                  return ListTile(
                    leading: Icon(
                      _getLocationIcon(location.type),
                      color: _getLocationColor(location.type),
                    ),
                    title: Text(location.name),
                    subtitle: Text(location.description),
                    onTap: () {
                      Navigator.pop(context);
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(location.latitude, location.longitude),
                          18,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLocationIcon(LocationType type) {
    switch (type) {
      case LocationType.building:
        return Icons.business;
      case LocationType.dining:
        return Icons.restaurant;
      case LocationType.sports:
        return Icons.sports;
      case LocationType.parking:
        return Icons.local_parking;
      case LocationType.emergency:
        return Icons.emergency;
      case LocationType.other:
        return Icons.place;
    }
  }

  Color _getLocationColor(LocationType type) {
    switch (type) {
      case LocationType.building:
        return AppTheme.primaryColor;
      case LocationType.dining:
        return AppTheme.warningColor;
      case LocationType.sports:
        return AppTheme.successColor;
      case LocationType.parking:
        return AppTheme.infoColor;
      case LocationType.emergency:
        return AppTheme.errorColor;
      case LocationType.other:
        return AppTheme.mediumColor;
    }
  }
}
