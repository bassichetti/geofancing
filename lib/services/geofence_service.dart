import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/geofence_area.dart';

class GeofenceService {
  static const String _storageKey = 'geofence_areas';

  // Salva uma área de geofencing
  Future<void> saveGeofenceArea(GeofenceArea area) async {
    final prefs = await SharedPreferences.getInstance();
    final areas = await getGeofenceAreas();

    // Remove área existente com mesmo ID (atualização)
    areas.removeWhere((existingArea) => existingArea.id == area.id);
    areas.add(area);

    final areasJson = areas.map((area) => area.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(areasJson));
  }

  // Obtém todas as áreas de geofencing
  Future<List<GeofenceArea>> getGeofenceAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final areasJson = prefs.getString(_storageKey);

    if (areasJson == null) return [];

    final List<dynamic> areasList = jsonDecode(areasJson);
    return areasList.map((areaMap) => GeofenceArea.fromMap(areaMap)).toList();
  }

  // Remove uma área de geofencing
  Future<void> deleteGeofenceArea(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final areas = await getGeofenceAreas();

    areas.removeWhere((area) => area.id == id);

    final areasJson = areas.map((area) => area.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(areasJson));
  }

  // Exporta todas as áreas como GeoJSON
  Future<String> exportToGeoJson() async {
    final areas = await getGeofenceAreas();

    final geoJson = {
      "type": "FeatureCollection",
      "features": areas.map((area) => area.toGeoJson()).toList(),
    };

    return jsonEncode(geoJson);
  }

  // Salva GeoJSON em arquivo
  Future<File> saveGeoJsonToFile() async {
    final geoJsonString = await exportToGeoJson();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/geofence_areas.geojson');

    return await file.writeAsString(geoJsonString);
  }

  // Importa áreas de um arquivo GeoJSON
  Future<void> importFromGeoJson(String geoJsonString) async {
    final geoJson = jsonDecode(geoJsonString);

    if (geoJson['type'] != 'FeatureCollection') {
      throw Exception('Formato GeoJSON inválido');
    }

    final features = geoJson['features'] as List;
    final areas =
        features.map((feature) => GeofenceArea.fromGeoJson(feature)).toList();

    // Salva todas as áreas importadas
    for (final area in areas) {
      await saveGeofenceArea(area);
    }
  }

  // Limpa todas as áreas
  Future<void> clearAllAreas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Atualiza o status ativo de uma área
  Future<void> toggleAreaStatus(String id) async {
    final areas = await getGeofenceAreas();
    final areaIndex = areas.indexWhere((area) => area.id == id);

    if (areaIndex != -1) {
      final updatedArea = areas[areaIndex].copyWith(
        isActive: !areas[areaIndex].isActive,
      );
      areas[areaIndex] = updatedArea;

      final prefs = await SharedPreferences.getInstance();
      final areasJson = areas.map((area) => area.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(areasJson));
    }
  }
}
