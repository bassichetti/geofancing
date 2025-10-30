# 🔧 Guia de Solução de Problemas

## 🌐 Problemas Web

### Erro: "Cannot read properties of undefined (reading 'maps')"

**Causa**: API JavaScript do Google Maps não carregada.

**Solução**:
1. Verifique se `web/index.html` contém:
   ```html
   <script async defer
     src="https://maps.googleapis.com/maps/api/js?key=SUA_CHAVE_DA_API_AQUI">
   </script>
   ```

2. Substitua `SUA_CHAVE_DA_API_AQUI` pela sua chave real

3. Configure restrições na API key para localhost:
   - `http://localhost:*`
   - `http://127.0.0.1:*`

### Mapa não carrega na web

**Possíveis causas**:
- ❌ API key não configurada
- ❌ Maps JavaScript API não habilitada
- ❌ Restrições bloqueando localhost
- ❌ Problemas de CORS

**Soluções**:
```bash
# 1. Limpe o cache
flutter clean
flutter pub get

# 2. Execute em modo debug
flutter run -d chrome --debug

# 3. Verifique console do navegador (F12)
```

### Erro de CORS na web

**Solução temporária**:
```bash
# Chrome sem segurança (apenas desenvolvimento)
flutter run -d chrome --web-browser-flag="--disable-web-security"
```

## 📱 Problemas Mobile

### GPS não funciona

**Android**:
1. Verifique permissões em Configurações > Apps > Geofancing > Permissões
2. Ative localização precisa
3. Teste em área externa (GPS funciona melhor fora de prédios)

**iOS**:
1. Configurações > Privacidade > Localização
2. Ative localização para o app
3. Escolha "Sempre" ou "Durante uso do app"

### App trava ao criar área

**Soluções**:
```bash
# 1. Reinicie o app
# 2. Limpe cache
flutter clean
flutter pub get

# 3. Recompile
flutter run
```

### Exportação GeoJSON falha

**Verificações**:
- ✅ Permissão de armazenamento concedida
- ✅ Espaço suficiente no dispositivo
- ✅ Pelo menos uma área criada

## 🛠️ Problemas de Compilação

### Erro Gradle (Android)

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error Pod Install (iOS)

```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
flutter run
```

### Dependências desatualizadas

```bash
# Atualizar para versões compatíveis
flutter pub outdated
flutter pub upgrade --major-versions

# Se houver conflitos
flutter pub deps
```

## 🔍 Debug e Diagnóstico

### Verificar configuração

```bash
# Verificar instalação Flutter
flutter doctor -v

# Verificar dependências
flutter pub deps

# Analisar código
flutter analyze

# Testar em dispositivo específico
flutter devices
flutter run -d <device-id>
```

### Logs detalhados

```bash
# Android
flutter logs

# iOS
flutter logs --verbose

# Web (console do navegador)
F12 → Console
```

### Performance

```bash
# Profile mode
flutter run --profile

# Release mode
flutter run --release

# Análise de performance
flutter run --trace-startup
```

## 🌍 Problemas de API

### Quota excedida

**Soluções**:
1. Verifique uso no [Google Cloud Console](https://console.cloud.google.com)
2. Configure limites diários menores
3. Otimize uso (cache, menos chamadas)

### API key inválida

**Verificações**:
- ✅ Chave copiada corretamente (sem espaços)
- ✅ APIs habilitadas (Maps SDK + JavaScript API)
- ✅ Restrições configuradas corretamente
- ✅ Faturamento ativado no projeto

### Problemas de localização

**Testes**:
```bash
# Usar localização simulada
flutter run --debug --dart-define=SIMULATE_LOCATION=true
```

## 📋 Checklist Geral

Antes de reportar um bug:

- [ ] Flutter doctor não mostra erros
- [ ] API key configurada corretamente
- [ ] Permissões concedidas
- [ ] Testado em dispositivo real
- [ ] Console sem erros JavaScript (web)
- [ ] Dependências atualizadas
- [ ] Cache limpo

## 📞 Suporte

Se o problema persistir:

1. **Documente o erro**:
   - Versão do Flutter
   - Plataforma (Android/iOS/Web)
   - Logs completos
   - Passos para reproduzir

2. **Consulte documentação**:
   - `GOOGLE_MAPS_CONFIG.md`
   - `WEB_SETUP.md`
   - `API_EXAMPLES.md`

3. **Reporte o bug**:
   - Abra uma issue no GitHub
   - Inclua informações completas
   - Anexe screenshots se relevante

---

**💡 Dica**: A maioria dos problemas está relacionada à configuração da API key do Google Maps!