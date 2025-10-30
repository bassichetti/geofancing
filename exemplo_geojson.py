#!/usr/bin/env python3
"""
Exemplo de script Python para trabalhar com dados GeoJSON do app Geofencing.
Este script demonstra como ler, processar e analisar dados exportados pelo app.

Instalação das dependências:
pip install geojson folium requests

Uso:
python3 exemplo_geojson.py geofence_areas.geojson
"""

import json
import sys
import math
from datetime import datetime
from typing import List, Dict, Any

def ler_geojson(arquivo: str) -> Dict[str, Any]:
    """Lê arquivo GeoJSON exportado pelo app."""
    try:
        with open(arquivo, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Arquivo {arquivo} não encontrado!")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Erro ao decodificar JSON do arquivo {arquivo}")
        sys.exit(1)

def analisar_areas(geojson_data: Dict[str, Any]) -> None:
    """Analisa e exibe estatísticas das áreas geofence."""
    features = geojson_data.get('features', [])
    
    if not features:
        print("Nenhuma área encontrada no arquivo!")
        return
    
    print(f"\n📊 ANÁLISE DAS ÁREAS GEOFENCE")
    print(f"{'='*50}")
    
    # Estatísticas gerais
    total_areas = len(features)
    areas_ativas = sum(1 for f in features if f['properties'].get('isActive', True))
    areas_circulares = sum(1 for f in features if f['properties'].get('type') == 'circle')
    areas_poligonais = sum(1 for f in features if f['properties'].get('type') == 'polygon')
    
    print(f"Total de áreas: {total_areas}")
    print(f"Áreas ativas: {areas_ativas}")
    print(f"Áreas inativas: {total_areas - areas_ativas}")
    print(f"Círculos: {areas_circulares}")
    print(f"Polígonos: {areas_poligonais}")
    
    # Análise por área
    print(f"\n📍 DETALHES DAS ÁREAS")
    print(f"{'='*50}")
    
    for i, feature in enumerate(features, 1):
        props = feature['properties']
        geom = feature['geometry']
        
        nome = props.get('name', f'Área {i}')
        tipo = props.get('type', 'unknown')
        ativa = '✅' if props.get('isActive', True) else '❌'
        cor = props.get('color', '#000000')
        criacao = props.get('createdAt', '')
        
        print(f"\n{i}. {nome} {ativa}")
        print(f"   Tipo: {tipo.title()}")
        print(f"   Cor: {cor}")
        
        if criacao:
            try:
                dt = datetime.fromisoformat(criacao.replace('Z', '+00:00'))
                print(f"   Criado: {dt.strftime('%d/%m/%Y %H:%M')}")
            except:
                print(f"   Criado: {criacao}")
        
        if tipo == 'circle':
            raio = props.get('radius', 0)
            coords = geom['coordinates']
            print(f"   Centro: {coords[1]:.6f}, {coords[0]:.6f}")
            print(f"   Raio: {raio}m")
            print(f"   Área: {math.pi * raio**2:.0f}m²")
            
        elif tipo == 'polygon':
            coords = geom['coordinates'][0]
            pontos = len(coords) - 1  # -1 porque o último ponto fecha o polígono
            print(f"   Pontos: {pontos}")
            
            # Calcular centro aproximado
            if coords:
                lat_avg = sum(coord[1] for coord in coords) / len(coords)
                lng_avg = sum(coord[0] for coord in coords) / len(coords)
                print(f"   Centro aprox.: {lat_avg:.6f}, {lng_avg:.6f}")

def gerar_relatorio_html(geojson_data: Dict[str, Any], output_file: str = 'relatorio_geofence.html') -> None:
    """Gera relatório HTML com mapa interativo das áreas."""
    try:
        import folium
        from folium import plugins
    except ImportError:
        print("Biblioteca 'folium' não encontrada. Instale com: pip install folium")
        return
    
    features = geojson_data.get('features', [])
    
    if not features:
        print("Nenhuma área para mapear!")
        return
    
    # Calcular centro do mapa baseado nas áreas
    lats, lngs = [], []
    for feature in features:
        geom = feature['geometry']
        if geom['type'] == 'Point':
            lngs.append(geom['coordinates'][0])
            lats.append(geom['coordinates'][1])
        elif geom['type'] == 'Polygon':
            for coord in geom['coordinates'][0]:
                lngs.append(coord[0])
                lats.append(coord[1])
    
    if lats and lngs:
        center_lat = sum(lats) / len(lats)
        center_lng = sum(lngs) / len(lngs)
    else:
        center_lat, center_lng = -23.5505, -46.6333  # São Paulo default
    
    # Criar mapa
    m = folium.Map(
        location=[center_lat, center_lng],
        zoom_start=13,
        tiles='OpenStreetMap'
    )
    
    # Adicionar áreas ao mapa
    for i, feature in enumerate(features, 1):
        props = feature['properties']
        geom = feature['geometry']
        
        nome = props.get('name', f'Área {i}')
        tipo = props.get('type', 'unknown')
        ativa = props.get('isActive', True)
        cor = props.get('color', '#2196F3')
        
        # Converter cor hex para nome/cor válida do folium
        if cor.startswith('#'):
            cor_folium = cor
        else:
            cor_folium = 'blue'
        
        popup_text = f"""
        <b>{nome}</b><br>
        Tipo: {tipo.title()}<br>
        Status: {'Ativa' if ativa else 'Inativa'}<br>
        Cor: {cor}
        """
        
        if not ativa:
            cor_folium = 'gray'
        
        if tipo == 'circle':
            raio = props.get('radius', 100)
            coords = geom['coordinates']
            
            folium.Circle(
                location=[coords[1], coords[0]],
                radius=raio,
                popup=popup_text,
                color=cor_folium,
                fill=True,
                opacity=0.7 if ativa else 0.3,
                fillOpacity=0.3 if ativa else 0.1
            ).add_to(m)
            
        elif tipo == 'polygon':
            coords = [[coord[1], coord[0]] for coord in geom['coordinates'][0]]
            
            folium.Polygon(
                locations=coords,
                popup=popup_text,
                color=cor_folium,
                fill=True,
                opacity=0.7 if ativa else 0.3,
                fillOpacity=0.3 if ativa else 0.1
            ).add_to(m)
    
    # Adicionar controles
    plugins.Fullscreen().add_to(m)
    folium.LayerControl().add_to(m)
    
    # Salvar mapa
    m.save(output_file)
    print(f"\n🗺️ Mapa interativo salvo em: {output_file}")

def verificar_sobreposicoes(geojson_data: Dict[str, Any]) -> None:
    """Verifica se existem áreas sobrepostas."""
    features = geojson_data.get('features', [])
    
    if len(features) < 2:
        print("\nNenhuma sobreposição possível (menos de 2 áreas)")
        return
    
    print(f"\n🔍 VERIFICAÇÃO DE SOBREPOSIÇÕES")
    print(f"{'='*50}")
    
    sobreposicoes_encontradas = False
    
    for i, area1 in enumerate(features):
        for j, area2 in enumerate(features[i+1:], i+1):
            if areas_se_sobrepoem(area1, area2):
                nome1 = area1['properties'].get('name', f'Área {i+1}')
                nome2 = area2['properties'].get('name', f'Área {j+1}')
                print(f"⚠️ Possível sobreposição: '{nome1}' e '{nome2}'")
                sobreposicoes_encontradas = True
    
    if not sobreposicoes_encontradas:
        print("✅ Nenhuma sobreposição detectada")

def areas_se_sobrepoem(area1: Dict, area2: Dict) -> bool:
    """Verifica se duas áreas se sobrepõem (implementação simplificada)."""
    # Esta é uma implementação básica que verifica apenas círculos
    # Para uma implementação completa, seria necessário usar bibliotecas como Shapely
    
    geom1, geom2 = area1['geometry'], area2['geometry']
    
    if geom1['type'] == 'Point' and geom2['type'] == 'Point':
        # Dois círculos
        coords1, coords2 = geom1['coordinates'], geom2['coordinates']
        raio1 = area1['properties'].get('radius', 100)
        raio2 = area2['properties'].get('radius', 100)
        
        # Calcular distância entre centros
        lat1, lng1 = coords1[1], coords1[0]
        lat2, lng2 = coords2[1], coords2[0]
        
        # Fórmula de Haversine simplificada para distâncias pequenas
        dlat = math.radians(lat2 - lat1)
        dlng = math.radians(lng2 - lng1)
        
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlng/2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        distancia = 6371000 * c  # Raio da Terra em metros
        
        return distancia < (raio1 + raio2)
    
    return False  # Para polígonos, retornamos False (não implementado)

def main():
    if len(sys.argv) != 2:
        print("Uso: python3 exemplo_geojson.py <arquivo_geojson>")
        print("Exemplo: python3 exemplo_geojson.py geofence_areas.geojson")
        sys.exit(1)
    
    arquivo_geojson = sys.argv[1]
    
    print("🌍 ANALISADOR DE DADOS GEOFENCE")
    print("="*50)
    print(f"Analisando arquivo: {arquivo_geojson}")
    
    # Ler dados
    dados = ler_geojson(arquivo_geojson)
    
    # Executar análises
    analisar_areas(dados)
    verificar_sobreposicoes(dados)
    
    # Gerar mapa (se folium estiver disponível)
    gerar_relatorio_html(dados)
    
    print(f"\n✅ Análise concluída!")

if __name__ == "__main__":
    main()