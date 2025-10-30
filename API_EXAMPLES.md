# Exemplos de Uso da API

Este documento contém exemplos práticos de como usar os principais componentes do app Geofancing.

## 📍 GeofenceService - Gerenciamento de Áreas

### Criando uma Área Circular

```dart
import 'package:geofancing/services/geofence_service.dart';
import 'package:geofancing/models/geofence_area.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final geofenceService = GeofenceService();

// Criar área circular
final circularArea = GeofenceArea(
  id: 'area_circular_001',
  name: 'Casa',
  type: GeofenceType.circle,
  center: const LatLng(-23.5505, -46.6333), // São Paulo
  radius: 100.0, // 100 metros
  color: const Color(0xFF2196F3),
  isActive: true,
);

// Salvar a área
await geofenceService.saveGeofenceArea(circularArea);
```

### Criando uma Área Poligonal

```dart
// Criar área poligonal (quadrado)
final polygonArea = GeofenceArea(
  id: 'area_poligono_001',
  name: 'Trabalho',
  type: GeofenceType.polygon,
  points: [
    const LatLng(-23.5505, -46.6333),
    const LatLng(-23.5510, -46.6333),
    const LatLng(-23.5510, -46.6340),
    const LatLng(-23.5505, -46.6340),
  ],
  color: const Color(0xFFFF5722),
  isActive: true,
);

await geofenceService.saveGeofenceArea(polygonArea);
```

### Listando Todas as Áreas

```dart
// Obter todas as áreas salvas
final List<GeofenceArea> areas = await geofenceService.getGeofenceAreas();

print('Total de áreas: ${areas.length}');
for (final area in areas) {
  print('${area.name}: ${area.type} - ${area.isActive ? "Ativa" : "Inativa"}');
}
```

### Exportando para GeoJSON

```dart
// Exportar todas as áreas como GeoJSON
final String geoJsonString = await geofenceService.exportToGeoJson();

// Salvar em arquivo
await geofenceService.saveGeoJsonToFile();
print('Arquivo GeoJSON salvo com sucesso!');
```

## 🌍 LocationService - Serviços de Localização

### Obtendo Localização Atual

```dart
import 'package:geofancing/services/location_service.dart';

final locationService = LocationService();

try {
  final Position position = await locationService.getCurrentLocation();
  print('Latitude: ${position.latitude}');
  print('Longitude: ${position.longitude}');
  print('Precisão: ${position.accuracy}m');
} catch (e) {
  print('Erro ao obter localização: $e');
}
```

### Verificando se Está Dentro de uma Área

```dart
// Verificar se um ponto está dentro de um círculo
final bool dentroDoCirculo = locationService.isPointInCircle(
  const LatLng(-23.5506, -46.6334), // ponto a verificar
  const LatLng(-23.5505, -46.6333), // centro do círculo
  100.0, // raio em metros
);

print('Dentro do círculo: $dentroDoCirculo');

// Verificar se um ponto está dentro de um polígono
final bool dentroDoPoligono = locationService.isPointInPolygon(
  const LatLng(-23.5507, -46.6335), // ponto a verificar
  [
    const LatLng(-23.5505, -46.6333),
    const LatLng(-23.5510, -46.6333),
    const LatLng(-23.5510, -46.6340),
    const LatLng(-23.5505, -46.6340),
  ], // pontos do polígono
);

print('Dentro do polígono: $dentroDoPoligono');
```

## 🗺️ Usando o MapScreen

### Integrando o Mapa na sua Aplicação

```dart
import 'package:flutter/material.dart';
import 'package:geofancing/screens/map_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geofancing Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
```

### Customizando o Mapa

```dart
// No MapScreen, você pode personalizar:

// 1. Posição inicial do mapa
static const LatLng _initialPosition = LatLng(-23.5505, -46.6333);

// 2. Estilo do mapa
GoogleMap(
  mapType: MapType.hybrid, // satellite, terrain, normal
  initialCameraPosition: const CameraPosition(
    target: _initialPosition,
    zoom: 15.0,
  ),
  // ... outros parâmetros
)
```

## 📱 Widgets Customizados

### Botão de Criação de Área

```dart
FloatingActionButton.extended(
  onPressed: () => _showCreateAreaDialog(),
  icon: const Icon(Icons.add_location),
  label: const Text('Nova Área'),
  backgroundColor: Theme.of(context).primaryColor,
)
```

### Lista de Áreas

```dart
ListView.builder(
  itemCount: areas.length,
  itemBuilder: (context, index) {
    final area = areas[index];
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: area.color,
        child: Icon(
          area.type == GeofenceType.circle 
            ? Icons.circle_outlined 
            : Icons.pentagon_outlined,
          color: Colors.white,
        ),
      ),
      title: Text(area.name),
      subtitle: Text(
        '${area.type == GeofenceType.circle ? "Círculo" : "Polígono"} - '
        '${area.isActive ? "Ativo" : "Inativo"}'
      ),
      trailing: Switch(
        value: area.isActive,
        onChanged: (value) => _toggleAreaStatus(area, value),
      ),
    );
  },
)
```

## 🎨 Personalizações Visuais

### Cores Personalizadas

```dart
// Paleta de cores predefinidas
final List<Color> availableColors = [
  const Color(0xFF2196F3), // Azul
  const Color(0xFF4CAF50), // Verde
  const Color(0xFFFF5722), // Laranja
  const Color(0xFF9C27B0), // Roxo
  const Color(0xFFFFEB3B), // Amarelo
  const Color(0xFFF44336), // Vermelho
];

// Aplicar cor personalizada
final area = GeofenceArea(
  // ... outros parâmetros
  color: availableColors[2], // Laranja
);
```

### Marcadores Customizados

```dart
// Criar marcador personalizado para centro do círculo
Marker createCenterMarker(GeofenceArea area) {
  return Marker(
    markerId: MarkerId('center_${area.id}'),
    position: area.center!,
    icon: BitmapDescriptor.defaultMarkerWithHue(
      _getHueFromColor(area.color),
    ),
    infoWindow: InfoWindow(
      title: area.name,
      snippet: 'Centro - Raio: ${area.radius?.toStringAsFixed(0)}m',
    ),
  );
}
```

## 🔄 Fluxo Completo de Uso

```dart
// Exemplo de uso completo do sistema
class GeofancingManager {
  final GeofenceService _geofenceService = GeofenceService();
  final LocationService _locationService = LocationService();
  
  // Monitorar posição atual contra todas as áreas
  Future<void> monitorCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    final areas = await _geofenceService.getGeofenceAreas();
    
    for (final area in areas.where((a) => a.isActive)) {
      bool isInside = false;
      
      if (area.type == GeofenceType.circle) {
        isInside = _locationService.isPointInCircle(
          LatLng(position.latitude, position.longitude),
          area.center!,
          area.radius!,
        );
      } else {
        isInside = _locationService.isPointInPolygon(
          LatLng(position.latitude, position.longitude),
          area.points!,
        );
      }
      
      if (isInside) {
        print('Você está dentro da área: ${area.name}');
        // Aqui você pode disparar notificações, logs, etc.
      }
    }
  }
}
```

## 🧪 Testando o Sistema

### Dados de Teste

```dart
// Criar áreas de teste para desenvolvimento
Future<void> createTestAreas() async {
  final service = GeofenceService();
  
  // Área de teste 1: Círculo pequeno
  await service.saveGeofenceArea(
    GeofenceArea(
      id: 'test_circle_1',
      name: 'Teste Círculo',
      type: GeofenceType.circle,
      center: const LatLng(-23.5505, -46.6333),
      radius: 50.0,
      color: Colors.blue,
      isActive: true,
    ),
  );
  
  // Área de teste 2: Polígono
  await service.saveGeofenceArea(
    GeofenceArea(
      id: 'test_polygon_1',
      name: 'Teste Polígono',
      type: GeofenceType.polygon,
      points: [
        const LatLng(-23.5500, -46.6330),
        const LatLng(-23.5500, -46.6340),
        const LatLng(-23.5510, -46.6340),
        const LatLng(-23.5510, -46.6330),
      ],
      color: Colors.red,
      isActive: true,
    ),
  );
}
```

---

## 📞 Suporte

Para mais exemplos e dúvidas:
- 📧 Abra uma [issue no GitHub](https://github.com/seu-usuario/geofancing/issues)
- 📚 Consulte a [documentação completa](README.md)
- 🗺️ Veja o [guia de configuração do Google Maps](GOOGLE_MAPS_CONFIG.md)