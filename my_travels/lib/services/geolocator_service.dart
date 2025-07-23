import 'package:geolocator/geolocator.dart';

class LocationService {
  double _latitude = 0;
  double _longitude = 0;
  double _altitude = 0;

  double get latitude => _latitude;

  double get longitude => _longitude;

  double get altitude => _altitude;

  Future<void> getDeviceLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Serviço de localização desativado.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permissão negada');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permissão permanentemente negada');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    _latitude = position.latitude;
    _longitude = position.longitude;
    _altitude = position.altitude;
  }
}
