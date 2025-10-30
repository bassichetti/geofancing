import 'package:flutter/material.dart';
import '../models/geofence_area.dart';
import '../services/geofence_service.dart';

class GeofenceListScreen extends StatefulWidget {
  const GeofenceListScreen({super.key});

  @override
  State<GeofenceListScreen> createState() => _GeofenceListScreenState();
}

class _GeofenceListScreenState extends State<GeofenceListScreen> {
  final GeofenceService _geofenceService = GeofenceService();
  List<GeofenceArea> _geofenceAreas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGeofenceAreas();
  }

  Future<void> _loadGeofenceAreas() async {
    setState(() {
      _isLoading = true;
    });

    final areas = await _geofenceService.getGeofenceAreas();

    setState(() {
      _geofenceAreas = areas;
      _isLoading = false;
    });
  }

  Future<void> _toggleAreaStatus(GeofenceArea area) async {
    await _geofenceService.toggleAreaStatus(area.id);
    await _loadGeofenceAreas();
  }

  Future<void> _deleteArea(GeofenceArea area) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a área "${area.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _geofenceService.deleteGeofenceArea(area.id);
      await _loadGeofenceAreas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Área "${area.name}" excluída com sucesso!')),
        );
      }
    }
  }

  Future<void> _exportGeoJson() async {
    try {
      final file = await _geofenceService.saveGeoJsonToFile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GeoJSON exportado para: ${file.path}'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }

  Future<void> _clearAllAreas() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Limpeza'),
        content: const Text('Tem certeza que deseja excluir todas as áreas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir Todas'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _geofenceService.clearAllAreas();
      await _loadGeofenceAreas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todas as áreas foram excluídas!')),
        );
      }
    }
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
        title: const Text('Áreas Geofence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportGeoJson,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllAreas();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Limpar Todas'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _geofenceAreas.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma área cadastrada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Use o mapa para criar suas primeiras áreas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGeofenceAreas,
                  child: ListView.builder(
                    itemCount: _geofenceAreas.length,
                    itemBuilder: (context, index) {
                      final area = _geofenceAreas[index];
                      final color = _parseColor(area.color);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: area.isActive
                                  ? color.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
                              border: Border.all(
                                color: area.isActive ? color : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              area.type == GeofenceType.circle
                                  ? Icons.radio_button_unchecked
                                  : Icons.pentagon_outlined,
                              color: area.isActive ? color : Colors.grey,
                            ),
                          ),
                          title: Text(
                            area.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: area.isActive ? null : Colors.grey,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                area.type == GeofenceType.circle
                                    ? 'Círculo - Raio: ${area.radius?.toInt()}m'
                                    : 'Polígono - ${area.coordinates.length} pontos',
                              ),
                              Text(
                                'Criado em: ${area.createdAt.day}/${area.createdAt.month}/${area.createdAt.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: area.isActive,
                                onChanged: (value) => _toggleAreaStatus(area),
                                activeColor: color,
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteArea(area),
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(area.name),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${area.id}'),
                                    Text(
                                        'Tipo: ${area.type == GeofenceType.circle ? 'Círculo' : 'Polígono'}'),
                                    if (area.radius != null)
                                      Text('Raio: ${area.radius!.toInt()}m'),
                                    Text('Pontos: ${area.coordinates.length}'),
                                    Text(
                                        'Ativo: ${area.isActive ? 'Sim' : 'Não'}'),
                                    Text(
                                        'Criado em: ${area.createdAt.day}/${area.createdAt.month}/${area.createdAt.year} às ${area.createdAt.hour}:${area.createdAt.minute.toString().padLeft(2, '0')}'),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          area.color,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Fechar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Voltar ao Mapa',
        child: const Icon(Icons.map),
      ),
    );
  }
}
