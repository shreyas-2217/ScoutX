import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dart:html' as html;

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class PlaceResult {
  final String name;
  final String address;
  final LatLng location;
  const PlaceResult({required this.name, required this.address, required this.location});
}

class LocationService {
  Future<bool> isLocationEnabled() async {
    if (kIsWeb) return true;
    return true;
  }

  Future<LocationPermissionStatus> checkPermission() async {
    return LocationPermissionStatus.granted;
  }

  Future<LocationPermissionStatus> requestPermission() async {
    return LocationPermissionStatus.granted;
  }

  Future<LatLng?> getCurrentPosition() async {
    if (kIsWeb) {
      return _getCurrentPositionWeb();
    }
    return null;
  }

  Future<LatLng?> _getCurrentPositionWeb() async {
    try {
      final pos = await html.window.navigator.geolocation.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 15),
      );
      return LatLng(pos.coords!.latitude!.toDouble(), pos.coords!.longitude!.toDouble());
    } catch (e) {
      return null;
    }
  }

  Future<List<PlaceResult>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': '$query, India',
        'format': 'json',
        'limit': '8',
        'addressdetails': '1',
        'dedupe': '0',
      });

      final response = await http.get(uri, headers: {
        'User-Agent': 'ScoutX/1.0',
      });

      if (response.statusCode != 200) return [];

      final List<dynamic> data = json.decode(response.body);
      List<PlaceResult> results = [];

      for (final item in data) {
        final lat = double.tryParse(item['lat'].toString());
        final lon = double.tryParse(item['lon'].toString());
        if (lat == null || lon == null) continue;

        final addr = item['address'] as Map<String, dynamic>?;
        final itemName = (item['name'] as String?) ?? '';

        final subtitleParts = <String>[];
        if (addr != null) {
          if (addr['suburb'] != null) subtitleParts.add(addr['suburb']);
          if (addr['city'] != null) subtitleParts.add(addr['city']);
          if (addr['state'] != null) subtitleParts.add(addr['state']);
          if (addr['country'] != null) subtitleParts.add(addr['country']);
        }
        final subtitle = subtitleParts.isNotEmpty
            ? subtitleParts.join(', ')
            : (item['display_name'] ?? query);

        results.add(PlaceResult(
          name: itemName.isNotEmpty ? itemName : (item['display_name'] ?? query),
          address: subtitle,
          location: LatLng(lat, lon),
        ));
      }

      if (results.isEmpty) {
        final retryUri = Uri.https('nominatim.openstreetmap.org', '/search', {
          'q': query,
          'format': 'json',
          'limit': '8',
          'addressdetails': '1',
          'dedupe': '0',
        });
        final retryResp = await http.get(retryUri, headers: {
          'User-Agent': 'ScoutX/1.0',
        });
        if (retryResp.statusCode == 200) {
          final List<dynamic> retryData = json.decode(retryResp.body);
          for (final item in retryData) {
            final lat = double.tryParse(item['lat'].toString());
            final lon = double.tryParse(item['lon'].toString());
            if (lat == null || lon == null) continue;

            final addr = item['address'] as Map<String, dynamic>?;
            final itemName = (item['name'] as String?) ?? '';

            final subtitleParts = <String>[];
            if (addr != null) {
              if (addr['suburb'] != null) subtitleParts.add(addr['suburb']);
              if (addr['city'] != null) subtitleParts.add(addr['city']);
              if (addr['state'] != null) subtitleParts.add(addr['state']);
              if (addr['country'] != null) subtitleParts.add(addr['country']);
            }
            final subtitle = subtitleParts.isNotEmpty
                ? subtitleParts.join(', ')
                : (item['display_name'] ?? query);

            results.add(PlaceResult(
              name: itemName.isNotEmpty ? itemName : (item['display_name'] ?? query),
              address: subtitle,
              location: LatLng(lat, lon),
            ));
          }
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'json',
      });

      final response = await http.get(uri, headers: {
        'User-Agent': 'ScoutX/1.0',
      });

      if (response.statusCode != 200) {
        return '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';
      }

      final data = json.decode(response.body);
      final addr = data['address'] as Map<String, dynamic>?;
      if (addr != null) {
        final parts = <String>[];
        if (addr['city'] != null) parts.add(addr['city']);
        if (addr['state'] != null) parts.add(addr['state']);
        if (addr['country'] != null) parts.add(addr['country']);
        if (parts.isNotEmpty) return parts.join(', ');
      }
      return data['display_name'] ?? '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';
    } catch (e) {
      return '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';
    }
  }

  static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)} km';
    } else {
      return '${km.round()} km';
    }
  }

  static String getDistanceLabel(double? km) {
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).round()} m away';
    if (km < 10) return '${km.toStringAsFixed(1)} km away';
    return '${km.round()} km away';
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}
