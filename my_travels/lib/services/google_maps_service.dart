import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../model/location_map_model.dart';

// The API key is loaded from the .env file.
final _apiKey = dotenv.env['ANDROID_MAPS_APIKEY'] ?? '';

/// A service class to interact with Google Maps Platform APIs.
class GoogleMapsService {
  /// The base URL for Google Maps API endpoints.
  static const _baseURL = 'https://maps.googleapis.com/maps/api';

  /// Searches for location predictions based on a user's input string.
  ///
  /// Uses the Google Places Autocomplete API.
  /// Returns an empty list on failure or if the API key is not configured.
  Future<List<LocationMapModel>> searchLocation(String location) async {
    try {
      if (_apiKey.isEmpty) {
        // debugPrint('API key is not configured');
        return [];
      }
      final uri = Uri.parse(
        '$_baseURL/place/autocomplete/json?input=$location&key=$_apiKey&language=pt_BR',
      );

      // debugPrint('searchLocation URI: $uri');
      final res = await http.get(uri);
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['status'] != 'OK') {
        // debugPrint(
        //   'Autocomplete failed: ${json['status']} - ${json['error_message'] ?? 'no message'}',
        // );
        return [];
      }
      final locations = (json['predictions'] as List).map((prediction) {
        // debugPrint('Prediction: ${prediction['description']}');
        return LocationMapModel(
          locationId: prediction['place_id'],
          description: prediction['description'],
          lat: 0,
          long: 0,
        );
      }).toList();

      return locations;
    } catch (e) {
      // debugPrint('Exception in searchLocation: $e');
      return [];
    }
  }

  /// Fetches the geometric details (latitude and longitude) for a given place ID.
  ///
  /// Uses the Google Places Details API.
  /// Returns null on failure or if the API key is not configured.
  Future<LocationMapModel?> placeDetail(
    String placeId,
    String description,
  ) async {
    try {
      if (_apiKey.isEmpty) {
        // debugPrint('API key is not configured');
        return null;
      }

      final uri = Uri.parse(
        '$_baseURL/place/details/json?place_id=$placeId&fields=geometry&key=$_apiKey',
      );
      // debugPrint('placeDetail URI: $uri');
      final res = await http.get(uri);
      // debugPrint('Status code: ${res.statusCode}');
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['status'] != 'OK') {
        // debugPrint(
        //   'Details fetch failed: ${json['status']} - ${json['error_message'] ?? 'no message'}',
        // );
        return null;
      }

      final loc = json['result']['geometry']['location'];
      final lat = (loc['lat'] as num).toDouble();
      final lng = (loc['lng'] as num).toDouble();
      // debugPrint('Location found: $lat, $lng');

      return LocationMapModel(
        locationId: placeId,
        description: description,
        lat: lat,
        long: lng,
      );
    } catch (e) {
      // debugPrint('Exception in placeDetail: $e');
      return null;
    }
  }

  /// Fetches the polyline coordinates to draw a route between two points.
  ///
  /// Uses the Google Directions API.
  /// Returns an empty list on failure or if the API key is not configured.
  Future<List<LatLng>> getRouteCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      if (_apiKey.isEmpty) {
        // debugPrint('API key is not configured');
        return [];
      }

      final url = Uri.parse(
        '$_baseURL/directions/json?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$_apiKey',
      );

      // debugPrint('Route Request URL: $url');
      final response = await http.get(url);
      final json = jsonDecode(response.body);

      if (json['status'] != 'OK') {
        // debugPrint(
        //   'Directions API Error: ${json['status']} - ${json['error_message'] ?? 'no message'}',
        // );
        return [];
      }

      final polyline = json['routes'][0]['overview_polyline']['points'];
      return _decodePolyline(polyline);
    } catch (e) {
      // debugPrint('Exception in getRouteCoordinates: $e');
      return [];
    }
  }

  /// Decodes an encoded polyline string into a list of [LatLng] points.
  List<LatLng> _decodePolyline(String encoded) {
    List<PointLatLng> result = PolylinePoints.decodePolyline(encoded);

    return result
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }
}
