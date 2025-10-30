# Configuração do Google Maps

Para usar o Google Maps neste aplicativo, você precisa configurar uma chave da API do Google Maps.

## 🔑 Obtendo a Chave da API

1. **Acesse o Google Cloud Console**
   - Vá para: https://console.cloud.google.com/

2. **Crie um novo projeto ou selecione um existente**
   - Clique em "Select a project" → "New Project"
   - Nome: "Geofencing App" (ou qualquer nome)

3. **Ative as APIs necessárias**
   - Vá para "APIs & Services" → "Library"
   - Ative as seguintes APIs:
     - **Maps SDK for Android**
     - **Maps SDK for iOS**
     - **Maps JavaScript API** (para web)

4. **Crie as credenciais**
   - Vá para "APIs & Services" → "Credentials"
   - Clique em "Create Credentials" → "API Key"
   - Copie a chave gerada

## 📱 Configuração no Projeto

### Android

1. **Abra o arquivo**: `/android/app/src/main/AndroidManifest.xml`

2. **Substitua a linha**:
   ```xml
   android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```
   Por:
   ```xml
   android:value="SUA_CHAVE_DA_API_AQUI"/>
   ```

### iOS

1. **Abra o arquivo**: `/ios/Runner/AppDelegate.swift`

2. **Substitua a linha**:
   ```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```
   Por:
   ```swift
   GMSServices.provideAPIKey("SUA_CHAVE_DA_API_AQUI")
   ```

### Web

1. **Abra o arquivo**: `/web/index.html`

2. **Substitua a linha**:
   ```html
   src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE">
   ```
   Por:
   ```html
   src="https://maps.googleapis.com/maps/api/js?key=SUA_CHAVE_DA_API_AQUI">
   ```

**⚠️ Importante para Web**:
- Para produção, configure restrições de domínio na API key
- Para desenvolvimento local, use `http://localhost:*` nas restrições
- A API JavaScript deve estar habilitada no Google Cloud Console

## 💰 Controle de Custos
   ```

## 🛡️ Restrições de Segurança (Recomendado)

### Para Android
1. No Google Cloud Console, vá para "Credentials"
2. Clique na sua API Key
3. Em "Application restrictions", selecione "Android apps"
4. Adicione o package name: `com.example.geofancing`
5. Para obter o SHA-1, execute no terminal:
   ```bash
   cd android
   ./gradlew signingReport
   ```

### Para iOS
1. Em "Application restrictions", selecione "iOS apps"
2. Adicione o Bundle ID: `com.example.geofancing`

## 💰 Controle de Custos

⚠️ **IMPORTANTE**: O Google Maps requer faturamento habilitado, mesmo para uso gratuito.

### Habilitando Faturamento (Obrigatório)
1. **Acesse**: https://console.cloud.google.com/billing
2. **Crie conta de faturamento** com cartão de crédito
3. **Vincule ao seu projeto** do Google Maps

### Cotas Gratuitas (Mensais)
- **Maps JavaScript API**: 28.500 carregamentos
- **Maps SDK Android**: 100.000 carregamentos  
- **Maps SDK iOS**: 100.000 carregamentos

### Proteção Contra Custos
1. **Configure alertas de faturamento**:
   - Vá para "Billing" → "Budgets & alerts"
   - Crie alertas para valores baixos (ex: R$ 50, R$ 100)

2. **Defina cotas opcionais**:
   - Vá para "APIs & Services" → "Quotas"
   - Defina limites diários para evitar surpresas

## 🧪 Testando a Configuração

1. **Execute o app**:
   ```bash
   flutter run
   ```

2. **Verifique se**:
   - O mapa carrega corretamente
   - Não há mensagens de erro no console
   - Você consegue navegar pelo mapa

## ⚠️ Problemas Comuns

### Erro: "BillingNotEnabledMapError"
- **Causa**: Faturamento não habilitado no Google Cloud
- **Solução**: Habilite faturamento em https://console.cloud.google.com/billing
- **Detalhes**: Consulte o arquivo `BILLING_ISSUE.md`

### Mapa aparece cinza
- Verifique se a API key está correta
- Confirme se as APIs estão ativadas
- Verifique se o faturamento está habilitado
- Verifique as restrições de aplicativo

### Erro de permissão
- Confirme se as permissões de localização estão no AndroidManifest.xml
- No iOS, verifique o Info.plist

### Erro de compilação iOS
- Execute `cd ios && pod install`
- Se necessário: `cd ios && pod repo update && pod install`

## 📋 Exemplo de Configuração

### AndroidManifest.xml (exemplo)
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyBvOkBwgglDrDacM5oFgbW3tUhFaEfBdE"/>
```

### AppDelegate.swift (exemplo)
```swift
GMSServices.provideAPIKey("AIzaSyBvOkBwgglDrDacM5oFgbW3tUhFaEfBdE")
```

⚠️ **IMPORTANTE**: Nunca compartilhe suas chaves da API publicamente! As chaves acima são apenas exemplos.

## 🚀 Após a configuração

Quando tudo estiver configurado, você terá:

- ✅ Mapas do Google com alta qualidade
- ✅ Suporte a satélite, terreno e híbrido
- ✅ Melhor performance em dispositivos móveis
- ✅ Integração nativa com Android e iOS
- ✅ Suporte a temas personalizados
- ✅ Melhor experiência do usuário

O app funcionará exatamente igual ao anterior, mas com a qualidade e recursos do Google Maps!