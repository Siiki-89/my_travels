import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/location_map_model.dart';

final _apiKey = dotenv.env['ANDROID_MAPS_APIKEY'] ?? '';

class GoogleMapsService {
  static const _baseURL = 'https://maps.googleapis.com/maps/api';

  Future<List<LocationMapModel>> searchLocation(String location) async {
    try {
      if (_apiKey.isEmpty) {
        print('API não configurada');
        return [];
      }
      final uri = Uri.parse(
        '$_baseURL/place/autocomplete/json?input=$location&key=$_apiKey&language=pt_BR',
      );

      print('searchLocation: $uri');
      final res = await http.get(uri);
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['status'] != 'OK') {
        print(
          'Autocomplete falhou: ${json['status']} - ${json['error_message'] ?? 'sem mensagem'}',
        );
        return [];
      }
      final locations = (json['predictions'] as List).map((prediction) {
        print('Previsão: ${prediction['description']}');
        return LocationMapModel(
          locationId: prediction['place_id'],
          description: prediction['description'],
          lat: 0,
          long: 0,
        );
      }).toList();

      return locations;
    } catch (e) {
      print('fetchPredictions: $e');
      return [];
    }
  }

  Future<LocationMapModel?> placeDetail(
    String placeId,
    String description,
  ) async {
    try {
      if (_apiKey.isEmpty) {
        print('API não configurada');
        return null;
      }

      final uri = Uri.parse(
        '$_baseURL/place/details/json?place_id=$placeId&fields=geometry&key=$_apiKey',
      );
      print('plaDetail URI: $uri');
      final res = await http.get(uri);
      print('status code: ${res.statusCode}');
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['status'] != 'OK') {
        print(
          '[ERRO] Detalhes falharam: ${json['status']} - ${json['error_message'] ?? 'sem mensagem'}',
        );
        return null;
      }

      // Extrai coordenadas do JSON
      final loc = json['result']['geometry']['location'];
      final lat = (loc['lat'] as num).toDouble();
      final lng = (loc['lng'] as num).toDouble();
      print('[DEBUG] Localização: $lat, $lng');

      return LocationMapModel(
        locationId: placeId,
        description: description,
        lat: lat,
        long: lng,
      );
    } catch (e) {
      print('[EXCEPTION] getPlaceDetail: $e');
      return null;
    }
  }
}
