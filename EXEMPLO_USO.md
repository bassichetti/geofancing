# Exemplo de Uso - Geofencing App

Este documento demonstra como usar o aplicativo de geofencing para criar, gerenciar e exportar áreas de cercas virtuais.

## 🚀 Primeiros Passos

### 1. Iniciando o Aplicativo
Quando você abrir o aplicativo, será apresentado com:
- Um mapa interativo centralizado na sua localização atual
- Três botões flutuantes no canto inferior direito:
  - **○** - Criar área circular
  - **⬟** - Criar polígono
  - **📍** - Centralizar na sua localização

### 2. Concedendo Permissões
Na primeira execução, o app solicitará permissões de localização:
- **Android**: Permitir "Localização precisa" e "Localização em segundo plano"
- **iOS**: Escolher "Permitir ao usar o App" ou "Permitir sempre"

## 📍 Criando Áreas Geofence

### Criando uma Área Circular

1. **Toque no botão circular (○)**
2. **Toque no mapa** onde deseja o centro do círculo
3. **Configure a área**:
   - Digite um nome descritivo (ex: "Casa", "Escritório")
   - Ajuste o raio usando o slider (10m a 1000m)
   - Escolha uma cor tocando no quadrado colorido
4. **Toque em "Salvar"**

**Exemplo**: Criar uma área "Casa" com raio de 150m ao redor da sua residência.

### Criando um Polígono

1. **Toque no botão polígono (⬟)**
2. **Toque no mapa** para adicionar pontos do polígono
   - Cada toque adiciona um ponto numerado
   - Mínimo de 3 pontos necessários
   - Os pontos são conectados automaticamente
3. **Toque em "Finalizar"** quando terminar de desenhar
4. **Configure a área**:
   - Digite um nome (ex: "Parque", "Shopping")
   - Escolha uma cor personalizada
5. **Toque em "Salvar"**

**Exemplo**: Criar um polígono ao redor de um parque ou área comercial.

## 📋 Gerenciando Áreas

### Visualizando Todas as Áreas
1. **Toque no ícone de lista** no AppBar
2. Veja todas as áreas cadastradas com:
   - Nome e tipo (círculo/polígono)
   - Status ativo/inativo
   - Data de criação
   - Cor personalizada

### Ativando/Desativando Áreas
- **No mapa**: Toque na área para ver opções
- **Na lista**: Use o switch ao lado de cada área
- Áreas inativas aparecem em cinza

### Editando Informações
1. **Toque na área** no mapa ou na lista
2. Veja detalhes completos
3. Opções disponíveis:
   - Ativar/Desativar
   - Excluir
   - Ver coordenadas

### Excluindo Áreas
1. **Na lista**: Toque no ícone de lixeira
2. **Confirme** a exclusão
3. **No mapa**: Toque na área → "Excluir"

## 📁 Exportando Dados

### Exportação Manual
1. **Toque no ícone de download** (↓) no AppBar
2. O arquivo GeoJSON será salvo na pasta Documents
3. Localização: `/Documents/geofence_areas.geojson`

### Formato do Arquivo Exportado
```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "id": "1234567890",
        "name": "Casa",
        "type": "circle",
        "radius": 150,
        "color": "#FF2196F3",
        "createdAt": "2024-01-01T12:00:00.000Z",
        "isActive": true
      },
      "geometry": {
        "type": "Point",
        "coordinates": [-46.6333, -23.5505]
      }
    }
  ]
}
```

## 🎨 Personalização Visual

### Escolhendo Cores
1. Durante a criação da área, toque no quadrado colorido
2. Use o seletor de cores para:
   - Arrastar no círculo para escolher matiz
   - Ajustar brilho e saturação
   - Visualizar prévia em tempo real

### Cores Recomendadas por Categoria
- **🏠 Residencial**: Azul (#2196F3)
- **🏢 Trabalho**: Verde (#4CAF50)
- **🛒 Compras**: Laranja (#FF9800)
- **🎯 Especiais**: Roxo (#9C27B0)
- **⚠️ Alertas**: Vermelho (#F44336)

## 📱 Dicas de Uso

### Melhor Precisão
- Use WiFi + GPS para melhor localização
- Evite usar em áreas com muitos prédios altos
- Prefira áreas abertas para maior precisão

### Organização
- Use nomes descritivos para suas áreas
- Mantenha cores consistentes por categoria
- Desative áreas que não usa temporariamente

### Performance
- Limite-se a 20-30 áreas ativas simultaneamente
- Use polígonos simples (poucos pontos)
- Mantenha raios de círculos apropriados (50-500m)

## 🛠️ Casos de Uso Comuns

### 1. Monitoramento Residencial
```
- Área: Casa (círculo 100m)
- Uso: Saber quando membros da família chegam/saem
- Cor: Azul
```

### 2. Controle de Horário Comercial
```
- Área: Escritório (polígono personalizado)
- Uso: Registro automático de presença
- Cor: Verde
```

### 3. Lembretes de Localização
```
- Área: Supermercado (círculo 200m)
- Uso: Lembrar da lista de compras
- Cor: Laranja
```

### 4. Segurança Familiar
```
- Área: Escola (polígono ao redor do prédio)
- Uso: Confirmar chegada segura das crianças
- Cor: Roxo
```

## 🔧 Solução de Problemas

### App não localiza posição
1. Verifique se o GPS está ativado
2. Confirme permissões de localização
3. Teste em área aberta (sem muitos prédios)

### Áreas não aparecem no mapa
1. Verifique se estão ativas (não em cinza)
2. Faça zoom adequado no mapa
3. Reinicie o app se necessário

### Exportação não funciona
1. Verifique permissões de armazenamento
2. Confirme espaço disponível no dispositivo
3. Tente criar/salvar uma área primeiro

## 📊 Limites e Especificações

### Limites Técnicos
- **Raio mínimo**: 10 metros
- **Raio máximo**: 1000 metros
- **Pontos por polígono**: 3 mínimo, 50 recomendado
- **Áreas recomendadas**: Até 50 áreas

### Precisão
- **GPS**: ±3-5 metros em condições ideais
- **Área urbana**: ±10-15 metros
- **Área coberta**: ±50+ metros

### Formatos Suportados
- **Exportação**: GeoJSON
- **Coordenadas**: WGS84 (latitude/longitude)
- **Projeção**: EPSG:4326

## 🎯 Próximos Passos

Agora que você sabe usar o básico, experimente:

1. **Criar diferentes tipos de áreas** para diversos propósitos
2. **Organizar por cores** para fácil identificação
3. **Exportar dados** para backup ou análise
4. **Combinar círculos e polígonos** para cobertura completa

O geofencing é uma ferramenta poderosa para automação baseada em localização. Use sua criatividade para encontrar novos casos de uso!