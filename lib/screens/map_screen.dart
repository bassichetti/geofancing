import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/geofence_area.dart';
import '../services/geofence_service.dart';
import '../services/location_service.dart';
import 'geofence_list_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final GeofenceService _geofenceService = GeofenceService();
  final LocationService _locationService = LocationService();

  List<GeofenceArea> _geofenceAreas = [];
  List<LatLng> _drawingPoints = [];
  GeofenceType _currentDrawingType = GeofenceType.polygon;
  bool _isDrawing = false;
  String _currentColor = '#FF2196F3';
  double _circleRadius = 100.0;
  LatLng? _currentLocation;

  Set<Marker> _markers = {};
  Set<Polygon> _polygons = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _loadGeofenceAreas();
    _getCurrentLocation();
  }

  Future<void> _loadGeofenceAreas() async {
    final areas = await _geofenceService.getGeofenceAreas();
    setState(() {
      _geofenceAreas = areas;
    });
    _updateMapElements();
  }

  Future<void> _getCurrentLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: location, zoom: 15.0),
          ),
        );
      }
    }
  }

  void _onMapTap(LatLng position) {
    if (!_isDrawing) return;

    setState(() {
      if (_currentDrawingType == GeofenceType.circle) {
        _drawingPoints = [position];
      } else {
        _drawingPoints.add(position);
      }
    });
    _updateDrawingMarkers();
  }

  void _updateDrawingMarkers() {
    Set<Marker> drawingMarkers = {};

    for (int i = 0; i < _drawingPoints.length; i++) {
      drawingMarkers.add(
        Marker(
          markerId: MarkerId('drawing_point_$i'),
          position: _drawingPoints[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _currentDrawingType == GeofenceType.circle
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: _currentDrawingType == GeofenceType.circle
                ? 'Centro do Círculo'
                : 'Ponto ${i + 1}',
          ),
        ),
      );
    }

    // Adicionar círculo temporário se estiver desenhando círculo
    Set<Circle> drawingCircles = {};
    if (_currentDrawingType == GeofenceType.circle &&
        _drawingPoints.isNotEmpty) {
      drawingCircles.add(
        Circle(
          circleId: const CircleId('drawing_circle'),
          center: _drawingPoints.first,
          radius: _circleRadius,
          fillColor: _parseColor(_currentColor).withValues(alpha: 0.3),
          strokeColor: _parseColor(_currentColor),
          strokeWidth: 2,
        ),
      );
    }

    // Adicionar polígono temporário se estiver desenhando polígono
    Set<Polygon> drawingPolygons = {};
    if (_currentDrawingType == GeofenceType.polygon &&
        _drawingPoints.length >= 3) {
      drawingPolygons.add(
        Polygon(
          polygonId: const PolygonId('drawing_polygon'),
          points: _drawingPoints,
          fillColor: _parseColor(_currentColor).withValues(alpha: 0.3),
          strokeColor: _parseColor(_currentColor),
          strokeWidth: 2,
        ),
      );
    }

    setState(() {
      // Combinar marcadores existentes com os de desenho
      _markers = Set.from(
          _markers.where((m) => !m.markerId.value.startsWith('drawing_')))
        ..addAll(drawingMarkers);
      _circles =
          Set.from(_circles.where((c) => c.circleId.value != 'drawing_circle'))
            ..addAll(drawingCircles);
      _polygons = Set.from(
          _polygons.where((p) => p.polygonId.value != 'drawing_polygon'))
        ..addAll(drawingPolygons);
    });
  }

  void _updateMapElements() {
    Set<Marker> newMarkers = {};
    Set<Circle> newCircles = {};
    Set<Polygon> newPolygons = {};

    // Adicionar marcador da localização atual
    if (_currentLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Sua Localização'),
        ),
      );
    }

    // Adicionar elementos das áreas geofence
    for (final area in _geofenceAreas) {
      final color = _parseColor(area.color);
      final isActive = area.isActive;

      if (area.type == GeofenceType.circle) {
        // Adicionar círculo
        newCircles.add(
          Circle(
            circleId: CircleId(area.id),
            center: area.coordinates.first,
            radius: area.radius ?? 100,
            fillColor: isActive
                ? color.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            strokeColor: isActive ? color : Colors.grey,
            strokeWidth: 2,
          ),
        );

        // Adicionar marcador no centro
        newMarkers.add(
          Marker(
            markerId: MarkerId('center_${area.id}'),
            position: area.coordinates.first,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isActive ? BitmapDescriptor.hueRed : BitmapDescriptor.hueViolet,
            ),
            infoWindow: InfoWindow(
              title: area.name,
              snippet: 'Raio: ${area.radius?.toInt()}m',
            ),
            onTap: () => _onAreaTap(area),
          ),
        );
      } else {
        // Adicionar polígono
        newPolygons.add(
          Polygon(
            polygonId: PolygonId(area.id),
            points: area.coordinates,
            fillColor: isActive
                ? color.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            strokeColor: isActive ? color : Colors.grey,
            strokeWidth: 2,
          ),
        );

        // Adicionar marcador no centro do polígono
        final center = _calculatePolygonCenter(area.coordinates);
        newMarkers.add(
          Marker(
            markerId: MarkerId('center_${area.id}'),
            position: center,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isActive ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueViolet,
            ),
            infoWindow: InfoWindow(
              title: area.name,
              snippet: '${area.coordinates.length} pontos',
            ),
            onTap: () => _onAreaTap(area),
          ),
        );
      }
    }

    setState(() {
      _markers = newMarkers;
      _circles = newCircles;
      _polygons = newPolygons;
    });
  }

  LatLng _calculatePolygonCenter(List<LatLng> points) {
    double lat = 0;
    double lng = 0;

    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }

    return LatLng(lat / points.length, lng / points.length);
  }

  void _startDrawing(GeofenceType type) {
    setState(() {
      _currentDrawingType = type;
      _isDrawing = true;
      _drawingPoints.clear();
    });
    _updateDrawingMarkers();
  }

  void _cancelDrawing() {
    setState(() {
      _isDrawing = false;
      _drawingPoints.clear();
    });
    _updateMapElements(); // Remove elementos de desenho
  }

  Future<void> _finishDrawing() async {
    if (_drawingPoints.isEmpty) return;

    if (_currentDrawingType == GeofenceType.polygon &&
        _drawingPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Um polígono precisa de pelo menos 3 pontos'),
        ),
      );
      return;
    }

    await _showNameDialog();
  }

  Future<void> _showNameDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Configurar Área'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nome da área',
                  hintText: 'Digite o nome da área',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_currentDrawingType == GeofenceType.circle) ...[
                Text('Raio: ${_circleRadius.toInt()}m'),
                Slider(
                  value: _circleRadius,
                  min: 10,
                  max: 1000,
                  divisions: 99,
                  label: '${_circleRadius.toInt()}m',
                  onChanged: (value) {
                    setState(() {
                      _circleRadius = value;
                    });
                    _updateDrawingMarkers(); // Atualiza o círculo em tempo real
                  },
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Text('Cor: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final color = await _showSimpleColorPicker();
                      if (color != null) {
                        setState(() {
                          _currentColor = color;
                        });
                        _updateDrawingMarkers(); // Atualiza a cor em tempo real
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                            int.parse(_currentColor.replaceFirst('#', '0xFF'))),
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.palette,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }
              Navigator.pop(dialogContext, {
                'name': name,
                'radius': _circleRadius,
                'color': _currentColor,
              });
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _saveGeofenceArea(result['name'] as String);
    }
  }

  Future<void> _saveGeofenceArea(String name) async {
    final area = GeofenceArea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: _currentDrawingType,
      coordinates: _drawingPoints,
      radius: _currentDrawingType == GeofenceType.circle ? _circleRadius : null,
      color: _currentColor,
      createdAt: DateTime.now(),
    );

    await _geofenceService.saveGeofenceArea(area);
    await _loadGeofenceAreas();

    setState(() {
      _isDrawing = false;
      _drawingPoints.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Área "$name" salva com sucesso!')),
    );
  }

  Future<String?> _showSimpleColorPicker() async {
    final colors = [
      '#FF2196F3', // Azul
      '#FF4CAF50', // Verde
      '#FFFF9800', // Laranja
      '#FF9C27B0', // Roxo
      '#FFF44336', // Vermelho
      '#FF607D8B', // Azul acinzentado
      '#FF795548', // Marrom
      '#FF009688', // Teal
      '#FFFF5722', // Vermelho escuro
      '#FF8BC34A', // Verde claro
    ];

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Cor'),
        content: SizedBox(
          width: 250,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color == _currentColor;

              return GestureDetector(
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 3)
                        : Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportGeoJson() async {
    try {
      final file = await _geofenceService.saveGeoJsonToFile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GeoJSON exportado para: ${file.path}'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    }
  }

  void _onAreaTap(GeofenceArea area) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(area.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Tipo: ${area.type == GeofenceType.circle ? 'Círculo' : 'Polígono'}'),
            if (area.radius != null) Text('Raio: ${area.radius!.toInt()}m'),
            Text('Ativo: ${area.isActive ? 'Sim' : 'Não'}'),
            Text(
                'Criado em: ${area.createdAt.day}/${area.createdAt.month}/${area.createdAt.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _geofenceService.toggleAreaStatus(area.id);
              await _loadGeofenceAreas();
              Navigator.pop(context);
            },
            child: Text(area.isActive ? 'Desativar' : 'Ativar'),
          ),
          TextButton(
            onPressed: () async {
              await _geofenceService.deleteGeofenceArea(area.id);
              await _loadGeofenceAreas();
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofencing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GeofenceListScreen(),
                ),
              );
              _loadGeofenceAreas();
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportGeoJson,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _currentLocation!, zoom: 15.0),
                  ),
                );
              }
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? const LatLng(-23.5505, -46.6333),
              zoom: 15.0,
            ),
            onTap: _onMapTap,
            markers: _markers,
            polygons: _polygons,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Usaremos nosso próprio botão
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          if (_isDrawing)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentDrawingType == GeofenceType.circle
                            ? 'Toque no mapa para definir o centro do círculo'
                            : 'Toque no mapa para adicionar pontos do polígono',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _cancelDrawing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed:
                                _drawingPoints.isEmpty ? null : _finishDrawing,
                            child: const Text('Finalizar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isDrawing
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'circle',
                  onPressed: () => _startDrawing(GeofenceType.circle),
                  child: const Icon(Icons.radio_button_unchecked),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'polygon',
                  onPressed: () => _startDrawing(GeofenceType.polygon),
                  child: const Icon(Icons.pentagon_outlined),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'location',
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
    );
  }
}
