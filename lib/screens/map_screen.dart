import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/geofence_area.dart';
import '../services/geofence_service.dart';
import '../services/location_service.dart';
import '../widgets/geofence_map_layer.dart';
import 'geofence_list_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final GeofenceService _geofenceService = GeofenceService();
  final LocationService _locationService = LocationService();

  List<GeofenceArea> _geofenceAreas = [];
  List<LatLng> _drawingPoints = [];
  GeofenceType _currentDrawingType = GeofenceType.polygon;
  bool _isDrawing = false;
  String _currentColor = '#FF2196F3';
  double _circleRadius = 100.0;
  LatLng? _currentLocation;

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
  }

  Future<void> _getCurrentLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location;
      });
      _mapController.move(location, 15.0);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    if (!_isDrawing) return;

    setState(() {
      if (_currentDrawingType == GeofenceType.circle) {
        _drawingPoints = [position];
      } else {
        _drawingPoints.add(position);
      }
    });
  }

  void _startDrawing(GeofenceType type) {
    setState(() {
      _currentDrawingType = type;
      _isDrawing = true;
      _drawingPoints.clear();
    });
  }

  void _cancelDrawing() {
    setState(() {
      _isDrawing = false;
      _drawingPoints.clear();
    });
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
                    // Apenas atualiza localmente, não precisa de setState aqui
                    _circleRadius = value;
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
                        _currentColor = color;
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentLocation ?? const LatLng(-23.5505, -46.6333),
              initialZoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              GeofenceMapLayer(
                geofenceAreas: _geofenceAreas,
                onAreaTap: _onAreaTap,
              ),
              if (_isDrawing)
                DrawingLayer(
                  points: _drawingPoints,
                  drawingType: _currentDrawingType,
                  color: _currentColor,
                  radius: _circleRadius,
                ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
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
