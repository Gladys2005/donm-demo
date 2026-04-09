import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../config/app_config.dart';

class LocationService {
  static final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;
  static final PolylinePoints _polylinePoints = PolylinePoints(apiKey: AppConfig.googleMapsApiKey);
  
  static StreamSubscription<Position>? _positionStreamSubscription;
  static Position? _currentPosition;
  static List<Placemark>? _currentAddress;
  
  // Get current position
  static Future<Position?> getCurrentPosition({bool forceUpdate = false}) async {
    try {
      if (!forceUpdate && _currentPosition != null) {
        return _currentPosition;
      }
      
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
      
      final position = await _geolocator.getCurrentPosition(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      _currentPosition = position;
      return position;
      
    } catch (e) {
      throw Exception('Failed to get current position: $e');
    }
  }
  
  // Start position stream
  static Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return _geolocator.getPositionStream(
      locationSettings: locationSettings ?? _getDefaultLocationSettings(),
    );
  }
  
  // Start listening to position updates
  static Future<void> startPositionUpdates({
    Function(Position)? onPositionChanged,
    Function(String)? onError,
  }) async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
      
      _positionStreamSubscription = getPositionStream().listen(
        (Position position) {
          _currentPosition = position;
          onPositionChanged?.call(position);
        },
        onError: (error) {
          onError?.call(error.toString());
        },
      );
      
    } catch (e) {
      onError?.call('Failed to start position updates: $e');
    }
  }
  
  // Stop position updates
  static Future<void> stopPositionUpdates() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
  
  // Get address from coordinates
  static Future<List<Placemark>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      
      _currentAddress = placemarks;
      return placemarks;
      
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }
  
  // Get coordinates from address
  static Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(
        address,
      );
      
      return locations;
      
    } catch (e) {
      throw Exception('Failed to get coordinates: $e');
    }
  }
  
  // Calculate distance between two points
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
  
  // Calculate distance in kilometers
  static double calculateDistanceInKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final distanceInMeters = calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distanceInMeters / 1000.0;
  }
  
  // Get polyline between two points
  static Future<List<LatLng>> getPolyline(
    LatLng start,
    LatLng end, {
    String travelMode = 'driving',
  }) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(end.latitude, end.longitude),
        travelMode: travelMode,
      );
      
      if (result.points.isNotEmpty) {
        return result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      }
      
      return [];
      
    } catch (e) {
      throw Exception('Failed to get polyline: $e');
    }
  }
  
  // Get multiple polylines for waypoints
  static Future<List<LatLng>> getPolylineWithWaypoints(
    LatLng start,
    List<LatLng> waypoints,
    LatLng end, {
    String travelMode = 'driving',
  }) async {
    try {
      final allPoints = <LatLng>[];
      allPoints.add(start);
      allPoints.addAll(waypoints);
      allPoints.add(end);
      
      final polylineCoordinates = <LatLng>[];
      
      for (int i = 0; i < allPoints.length - 1; i++) {
        final segment = await getPolyline(
          allPoints[i],
          allPoints[i + 1],
          travelMode: travelMode,
        );
        polylineCoordinates.addAll(segment);
      }
      
      return polylineCoordinates;
      
    } catch (e) {
      throw Exception('Failed to get polyline with waypoints: $e');
    }
  }
  
  // Get formatted address
  static String formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    
    if (placemark.subLocality?.isNotEmpty == true) {
      parts.add(placemark.subLocality!);
    }
    
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    
    if (placemark.country?.isNotEmpty == true) {
      parts.add(placemark.country!);
    }
    
    return parts.join(', ');
  }
  
  // Get current formatted address
  static Future<String?> getCurrentFormattedAddress() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;
      
      final placemarks = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        return formatAddress(placemarks.first);
      }
      
      return null;
      
    } catch (e) {
      return null;
    }
  }
  
  // Check if location is within delivery area
  static bool isWithinDeliveryArea(LatLng location) {
    // Define delivery area boundaries for Abidjan
    const double minLat = 5.15;
    const double maxLat = 5.45;
    const double minLng = -4.10;
    const double maxLng = -3.90;
    
    return location.latitude >= minLat &&
        location.latitude <= maxLat &&
        location.longitude >= minLng &&
        location.longitude <= maxLng;
  }
  
  // Find nearby delivery persons
  static Future<List<Map<String, dynamic>>> findNearbyDeliveryPersons(
    LatLng userLocation, {
    double radiusKm = 5.0,
  }) async {
    try {
      // This would integrate with your backend API
      // For now, return mock data
      return [
        {
          'id': '1',
          'name': 'John Doe',
          'location': LatLng(userLocation.latitude + 0.01, userLocation.longitude + 0.01),
          'distance': calculateDistanceInKm(
            userLocation.latitude,
            userLocation.longitude,
            userLocation.latitude + 0.01,
            userLocation.longitude + 0.01,
          ),
          'rating': 4.5,
          'isAvailable': true,
        },
        {
          'id': '2',
          'name': 'Jane Smith',
          'location': LatLng(userLocation.latitude - 0.01, userLocation.longitude + 0.01),
          'distance': calculateDistanceInKm(
            userLocation.latitude,
            userLocation.longitude,
            userLocation.latitude - 0.01,
            userLocation.longitude + 0.01,
          ),
          'rating': 4.8,
          'isAvailable': true,
        },
      ];
      
    } catch (e) {
      throw Exception('Failed to find nearby delivery persons: $e');
    }
  }
  
  // Get place suggestions (autocomplete)
  static Future<List<Map<String, dynamic>>> getPlaceSuggestions(
    String input, {
    String? sessionToken,
    String? types,
    String? components,
  }) async {
    try {
      final url = Uri.https(
        'maps.googleapis.com',
        'maps/api/place/autocomplete/json',
        {
          'input': input,
          'key': AppConfig.googleMapsApiKey,
          'sessiontoken': sessionToken,
          'types': types ?? 'address',
          'components': components ?? 'country:ci',
        },
      );
      
      // This would use an HTTP client to make the request
      // For now, return mock data
      return [
        {
          'place_id': '1',
          'description': 'Abidjan, Côte d\'Ivoire',
          'structured_formatting': {
            'main_text': 'Abidjan',
            'secondary_text': 'Côte d\'Ivoire',
          },
        },
        {
          'place_id': '2',
          'description': 'Plateau, Abidjan, Côte d\'Ivoire',
          'structured_formatting': {
            'main_text': 'Plateau',
            'secondary_text': 'Abidjan, Côte d\'Ivoire',
          },
        },
      ];
      
    } catch (e) {
      throw Exception('Failed to get place suggestions: $e');
    }
  }
  
  // Get place details
  static Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.https(
        'maps.googleapis.com',
        'maps/api/place/details/json',
        {
          'place_id': placeId,
          'key': AppConfig.googleMapsApiKey,
          'fields': 'name,formatted_address,geometry,place_id',
        },
      );
      
      // This would use an HTTP client to make the request
      // For now, return mock data
      return {
        'place_id': placeId,
        'name': 'Plateau',
        'formatted_address': 'Plateau, Abidjan, Côte d\'Ivoire',
        'geometry': {
          'location': {
            'lat': 5.3600,
            'lng': -4.0083,
          },
        },
      };
      
    } catch (e) {
      throw Exception('Failed to get place details: $e');
    }
  }
  
  // Check location permission
  static Future<bool> _checkLocationPermission() async {
    try {
      final permission = await Permission.location.request();
      return permission == PermissionStatus.granted ||
          permission == PermissionStatus.limited;
    } catch (e) {
      return false;
    }
  }
  
  // Get default location settings
  static LocationSettings _getDefaultLocationSettings() {
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // meters
      timeLimit: Duration(seconds: 30),
    );
  }
  
  // Open location settings
  static Future<void> openLocationSettings() async {
    await openAppSettings();
  }
  
  // Get current position or last known
  static Future<Position?> getCurrentOrLastPosition() async {
    try {
      return await getCurrentPosition();
    } catch (e) {
      // Fallback to last known position
      return await _geolocator.getLastKnownPosition();
    }
  }
  
  // Check if GPS is enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await _geolocator.isLocationServiceEnabled();
  }
  
  // Request location service
  static Future<bool> requestLocationService() async {
    return await _geolocator.openLocationSettings();
  }
  
  // Get location accuracy
  static LocationAccuracy getLocationAccuracy(double accuracy) {
    if (accuracy < 10) {
      return LocationAccuracy.high;
    } else if (accuracy < 100) {
      return LocationAccuracy.medium;
    } else {
      return LocationAccuracy.low;
    }
  }
  
  // Format distance
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
  
  // Format duration
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }
  
  // Dispose resources
  static void dispose() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
}
