import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Verifica e solicita permissões de localização
  Future<bool> requestLocationPermission() async {
    // Verifica permissão do sistema
    var status = await Permission.location.status;

    if (status.isDenied) {
      // Solicita permissão
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      // Abre configurações se permanentemente negada
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  // Obtém a localização atual
  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // Log error - em produção, use um sistema de logging adequado
      // print('Erro ao obter localização: $e');
      return null;
    }
  }

  // Monitora mudanças de localização
  Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Atualiza a cada 10 metros
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  // Verifica se um ponto está dentro de um círculo
  bool isPointInCircle(LatLng point, LatLng center, double radiusInMeters) {
    final distance = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      center.latitude,
      center.longitude,
    );

    return distance <= radiusInMeters;
  }

  // Verifica se um ponto está dentro de um polígono usando ray casting
  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude) &&
          point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  // Calcula a distância entre dois pontos em metros
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // Calcula o centro de um polígono
  LatLng calculatePolygonCenter(List<LatLng> polygon) {
    if (polygon.isEmpty) return const LatLng(0, 0);

    double lat = 0;
    double lng = 0;

    for (final point in polygon) {
      lat += point.latitude;
      lng += point.longitude;
    }

    return LatLng(lat / polygon.length, lng / polygon.length);
  }
}
