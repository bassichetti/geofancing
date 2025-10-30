# Geofencing App

Uma aplicação Flutter completa para criação e gerenciamento de áreas de geofencing (cercas virtuais) com suporte a polígonos e círculos, com exportação para formato GeoJSON.

## 🚀 Funcionalidades

### ✨ Principais Recursos
- **Criação de Áreas Circulares**: Defina círculos com raio ajustável
- **Criação de Polígonos**: Desenhe polígonos personalizados no mapa
- **Personalização Visual**: Escolha cores personalizadas para cada área
- **Gerenciamento Completo**: Liste, ative/desative e exclua áreas
- **Exportação GeoJSON**: Exporte todas as áreas como arquivo GeoJSON padrão
- **Localização em Tempo Real**: Visualize sua posição atual no mapa
- **Interface Intuitiva**: Design moderno e fácil de usar

### 🗺️ Recursos do Mapa
- Mapa interativo com OpenStreetMap
- Visualização de áreas ativas e inativas
- Marcadores para centros de círculos
- Numeração de pontos em polígonos
- Zoom e navegação fluida

### 💾 Armazenamento
- Persistência local usando SharedPreferences
- Exportação para arquivos GeoJSON
- Backup automático das configurações

## 📱 Como Usar

### Criando uma Área Circular
1. Toque no botão circular (○) no canto inferior direito
2. Toque no mapa onde deseja o centro do círculo
3. Digite o nome da área
4. Ajuste o raio usando o slider
5. Escolha uma cor personalizada
6. Toque em "Salvar"

### Criando um Polígono
1. Toque no botão polígono (⬟) no canto inferior direito
2. Toque no mapa para adicionar pontos do polígono
3. Adicione pelo menos 3 pontos
4. Toque em "Finalizar"
5. Digite o nome da área
6. Escolha uma cor personalizada
7. Toque em "Salvar"

### Gerenciando Áreas
- **Visualizar Todas**: Toque no ícone de lista no AppBar
- **Ativar/Desativar**: Use o switch na lista ou toque na área
- **Excluir**: Toque no ícone de lixeira na lista
- **Exportar**: Toque no ícone de download para gerar GeoJSON

## 🛠️ Instalação e Configuração

### Pré-requisitos
- Flutter SDK (≥ 3.6.0)
- Dart SDK
- Android Studio / VS Code
- Emulador ou dispositivo físico

### Dependências Principais
```yaml
dependencies:
  flutter_map: ^7.0.2          # Mapas interativos
  latlong2: ^0.9.1            # Coordenadas geográficas
  geolocator: ^12.0.0         # Serviços de localização
  permission_handler: ^11.3.1  # Gerenciamento de permissões
  flutter_colorpicker: ^1.1.0  # Seletor de cores
  shared_preferences: ^2.3.2   # Armazenamento local
  path_provider: ^2.1.4       # Acesso ao sistema de arquivos
```

### Configuração

1. **Clone o repositório**:
```bash
git clone <repository-url>
cd geofancing
```

2. **Instale as dependências**:
```bash
flutter pub get
```

3. **Execute a aplicação**:
```bash
flutter run
```

### Permissões

A aplicação solicita as seguintes permissões:

**Android**:
- `ACCESS_FINE_LOCATION`: Localização precisa
- `ACCESS_COARSE_LOCATION`: Localização aproximada
- `ACCESS_BACKGROUND_LOCATION`: Localização em background
- `WRITE_EXTERNAL_STORAGE`: Escrita de arquivos
- `INTERNET`: Acesso à internet para mapas

**iOS**:
- `NSLocationWhenInUseUsageDescription`: Localização durante uso
- `NSLocationAlwaysAndWhenInUseUsageDescription`: Localização sempre
- `NSLocationAlwaysUsageDescription`: Localização contínua

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                          # Ponto de entrada da aplicação
├── models/
│   └── geofence_area.dart            # Modelo de dados da área
├── services/
│   ├── geofence_service.dart         # Serviço de gerenciamento de áreas
│   └── location_service.dart         # Serviço de localização
├── screens/
│   ├── map_screen.dart               # Tela principal do mapa
│   └── geofence_list_screen.dart     # Tela de listagem de áreas
└── widgets/
    └── geofence_map_layer.dart       # Componentes do mapa
```

## 🌐 Formato GeoJSON

As áreas são exportadas no formato GeoJSON padrão:

### Círculo
```json
{
  "type": "Feature",
  "properties": {
    "id": "unique_id",
    "name": "Nome da Área",
    "type": "circle",
    "radius": 100,
    "color": "#FF2196F3",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "isActive": true
  },
  "geometry": {
    "type": "Point",
    "coordinates": [-46.6333, -23.5505]
  }
}
```

### Polígono
```json
{
  "type": "Feature",
  "properties": {
    "id": "unique_id",
    "name": "Nome da Área",
    "type": "polygon",
    "color": "#FF2196F3",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "isActive": true
  },
  "geometry": {
    "type": "Polygon",
    "coordinates": [[
      [-46.6333, -23.5505],
      [-46.6334, -23.5506],
      [-46.6335, -23.5507],
      [-46.6333, -23.5505]
    ]]
  }
}
```

## 🎨 Recursos Visuais

- **Cores Personalizáveis**: Cada área pode ter sua própria cor
- **Transparência**: Áreas preenchidas com transparência para melhor visualização
- **Estados Visuais**: Áreas inativas são mostradas em cinza
- **Marcadores Numerados**: Pontos de polígonos são numerados para facilitar edição
- **Tema Adaptável**: Suporte a tema claro e escuro

## 🔧 Personalização

### Alterando o Provedor de Mapas
Por padrão, usa OpenStreetMap. Para usar outros provedores, modifique em `map_screen.dart`:

```dart
TileLayer(
  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  subdomains: const ['a', 'b', 'c'],
),
```

### Configurando Precisão de Localização
Ajuste a precisão em `location_service.dart`:

```dart
final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high, // ou .medium, .low
);
```

## 📊 Algoritmos Utilizados

### Detecção de Ponto em Polígono
Utiliza o algoritmo **Ray Casting** para determinar se um ponto está dentro de um polígono.

### Cálculo de Distâncias
Usa a fórmula de **Haversine** através do package `geolocator` para cálculos precisos de distância.

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🆘 Suporte

Se encontrar problemas ou tiver dúvidas:

1. Verifique se todas as dependências foram instaladas corretamente
2. Confirme que as permissões foram concedidas no dispositivo
3. Verifique a conectividade com a internet para carregamento dos mapas
4. Consulte os logs do Flutter para mensagens de erro específicas

## � Arquivos de Exemplo

O projeto inclui arquivos de exemplo para demonstrar o uso:

- **`EXEMPLO_USO.md`**: Guia detalhado de como usar o aplicativo
- **`exemplo_geojson.py`**: Script Python para analisar dados exportados
- **`exemplo_dados.geojson`**: Arquivo de exemplo com dados de demonstração

### Testando com Dados de Exemplo

```bash
# Instalar dependências Python (opcional)
pip3 install folium geojson

# Executar análise dos dados de exemplo
python3 exemplo_geojson.py exemplo_dados.geojson
```

## �🚀 Roadmap

- [ ] Importação de arquivos GeoJSON
- [ ] Notificações de entrada/saída de áreas
- [ ] Histórico de movimentação
- [ ] Sincronização em nuvem
- [ ] Compartilhamento de áreas
- [ ] Suporte a mais formatos de exportação (KML, Shapefile)
- [ ] API para integração com outros sistemas
- [ ] Modo offline com sincronização posterior
- [ ] Estatísticas de uso e relatórios
- [ ] Integração com mapas satelitais
# geofancing
