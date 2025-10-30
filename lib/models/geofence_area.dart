import 'package:latlong2/latlong.dart';

enum GeofenceType { circle, polygon }

class GeofenceArea {
  final String id;
  final String name;
  final GeofenceType type;
  final List<LatLng> coordinates;
  final double? radius; // Para áreas circulares
  final String color;
  final DateTime createdAt;
  final bool isActive;

  GeofenceArea({
    required this.id,
    required this.name,
    required this.type,
    required this.coordinates,
    this.radius,
    required this.color,
    required this.createdAt,
    this.isActive = true,
  });

  // Converte para GeoJSON
  Map<String, dynamic> toGeoJson() {
    if (type == GeofenceType.circle) {
      return {
        "type": "Feature",
        "properties": {
          "id": id,
          "name": name,
          "type": "circle",
          "radius": radius,
          "color": color,
          "createdAt": createdAt.toIso8601String(),
          "isActive": isActive,
        },
        "geometry": {
          "type": "Point",
          "coordinates": [
            coordinates.first.longitude,
            coordinates.first.latitude,
          ]
        }
      };
    } else {
      // Polígono
      List<List<double>> polygonCoordinates = coordinates
          .map((coord) => [coord.longitude, coord.latitude])
          .toList();

      // Fechar o polígono se necessário
      if (coordinates.length > 2 &&
          (coordinates.first.latitude != coordinates.last.latitude ||
              coordinates.first.longitude != coordinates.last.longitude)) {
        polygonCoordinates.add([
          coordinates.first.longitude,
          coordinates.first.latitude,
        ]);
      }

      return {
        "type": "Feature",
        "properties": {
          "id": id,
          "name": name,
          "type": "polygon",
          "color": color,
          "createdAt": createdAt.toIso8601String(),
          "isActive": isActive,
        },
        "geometry": {
          "type": "Polygon",
          "coordinates": [polygonCoordinates]
        }
      };
    }
  }

  // Cria a partir de GeoJSON
  factory GeofenceArea.fromGeoJson(Map<String, dynamic> geoJson) {
    final properties = geoJson['properties'] as Map<String, dynamic>;
    final geometry = geoJson['geometry'] as Map<String, dynamic>;

    List<LatLng> coordinates = [];
    double? radius;
    GeofenceType type;

    if (geometry['type'] == 'Point') {
      // Área circular
      final coords = geometry['coordinates'] as List;
      coordinates = [LatLng(coords[1], coords[0])];
      radius = properties['radius']?.toDouble();
      type = GeofenceType.circle;
    } else {
      // Polígono
      final coords = geometry['coordinates'][0] as List;
      coordinates =
          coords.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
      type = GeofenceType.polygon;
    }

    return GeofenceArea(
      id: properties['id'],
      name: properties['name'],
      type: type,
      coordinates: coordinates,
      radius: radius,
      color: properties['color'],
      createdAt: DateTime.parse(properties['createdAt']),
      isActive: properties['isActive'] ?? true,
    );
  }

  // Converte para Map para storage local
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'coordinates': coordinates
          .map((coord) => {'lat': coord.latitude, 'lng': coord.longitude})
          .toList(),
      'radius': radius,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Cria a partir de Map do storage local
  factory GeofenceArea.fromMap(Map<String, dynamic> map) {
    return GeofenceArea(
      id: map['id'],
      name: map['name'],
      type: map['type'] == 'GeofenceType.circle'
          ? GeofenceType.circle
          : GeofenceType.polygon,
      coordinates: (map['coordinates'] as List)
          .map<LatLng>((coord) => LatLng(coord['lat'], coord['lng']))
          .toList(),
      radius: map['radius']?.toDouble(),
      color: map['color'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }

  GeofenceArea copyWith({
    String? name,
    List<LatLng>? coordinates,
    double? radius,
    String? color,
    bool? isActive,
  }) {
    return GeofenceArea(
      id: id,
      name: name ?? this.name,
      type: type,
      coordinates: coordinates ?? this.coordinates,
      radius: radius ?? this.radius,
      color: color ?? this.color,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
