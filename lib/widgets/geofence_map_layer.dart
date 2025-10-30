import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/geofence_area.dart';

class GeofenceMapLayer extends StatelessWidget {
  final List<GeofenceArea> geofenceAreas;
  final Function(GeofenceArea)? onAreaTap;

  const GeofenceMapLayer({
    super.key,
    required this.geofenceAreas,
    this.onAreaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Polígonos
        PolygonLayer(
          polygons: geofenceAreas
              .where((area) => area.type == GeofenceType.polygon)
              .map((area) => _buildPolygon(area))
              .toList(),
        ),
        // Círculos
        CircleLayer(
          circles: geofenceAreas
              .where((area) => area.type == GeofenceType.circle)
              .map((area) => _buildCircle(area))
              .toList(),
        ),
        // Marcadores para centros dos círculos
        MarkerLayer(
          markers: geofenceAreas
              .where((area) => area.type == GeofenceType.circle)
              .map((area) => _buildCircleMarker(area))
              .toList(),
        ),
      ],
    );
  }

  Polygon _buildPolygon(GeofenceArea area) {
    final color = _parseColor(area.color);

    return Polygon(
      points: area.coordinates,
      color: area.isActive
          ? color.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.2),
      borderColor: area.isActive ? color : Colors.grey,
      borderStrokeWidth: 2.0,
    );
  }

  CircleMarker _buildCircle(GeofenceArea area) {
    final color = _parseColor(area.color);

    return CircleMarker(
      point: area.coordinates.first,
      radius: area.radius ?? 100,
      color: area.isActive
          ? color.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.2),
      borderColor: area.isActive ? color : Colors.grey,
      borderStrokeWidth: 2.0,
      useRadiusInMeter: true,
    );
  }

  Marker _buildCircleMarker(GeofenceArea area) {
    final color = _parseColor(area.color);

    return Marker(
      point: area.coordinates.first,
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: () => onAreaTap?.call(area),
        child: Container(
          decoration: BoxDecoration(
            color: area.isActive ? color : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            Icons.location_on,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}

// Widget para desenhar área em criação
class DrawingLayer extends StatelessWidget {
  final List<LatLng> points;
  final GeofenceType drawingType;
  final String color;
  final double? radius;

  const DrawingLayer({
    super.key,
    required this.points,
    required this.drawingType,
    required this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return Container();

    final parsedColor = _parseColor(color);

    if (drawingType == GeofenceType.circle && points.isNotEmpty) {
      return Stack(
        children: [
          CircleLayer(
            circles: [
              CircleMarker(
                point: points.first,
                radius: radius ?? 100,
                color: parsedColor.withValues(alpha: 0.3),
                borderColor: parsedColor,
                borderStrokeWidth: 2.0,
                useRadiusInMeter: true,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: points.first,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: parsedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (drawingType == GeofenceType.polygon) {
      return Stack(
        children: [
          // Polígono (se tiver pelo menos 3 pontos)
          if (points.length >= 3)
            PolygonLayer(
              polygons: [
                Polygon(
                  points: points,
                  color: parsedColor.withValues(alpha: 0.3),
                  borderColor: parsedColor,
                  borderStrokeWidth: 2.0,
                ),
              ],
            ),
          // Linha (se tiver pelo menos 2 pontos)
          if (points.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  color: parsedColor,
                  strokeWidth: 2.0,
                ),
              ],
            ),
          // Marcadores para cada ponto
          MarkerLayer(
            markers: points
                .asMap()
                .entries
                .map((entry) => Marker(
                      point: entry.value,
                      width: 16,
                      height: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: parsedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      );
    }

    return Container();
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
