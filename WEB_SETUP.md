# Configuração para Desenvolvimento Web Local

## Problema: Google Maps não carrega na web

Se você está vendo o erro:
```
TypeError: Cannot read properties of undefined (reading 'maps')
```

Isso significa que a API JavaScript do Google Maps não foi carregada corretamente.

## Solução Rápida

### 1. Configure sua API Key no arquivo web/index.html

Substitua `YOUR_API_KEY_HERE` pela sua chave real:

```html
<script async defer
  src="https://maps.googleapis.com/maps/api/js?key=SUA_CHAVE_DA_API_AQUI">
</script>
```

### 2. Para desenvolvimento local

Se você está testando localmente (`flutter run -d chrome`), configure restrições na sua API key:

1. Vá para [Google Cloud Console](https://console.cloud.google.com/)
2. APIs & Services → Credentials
3. Clique na sua API key
4. Em "Application restrictions", selecione "HTTP referrers"
5. Adicione:
   - `http://localhost:*`
   - `http://127.0.0.1:*`
   - `https://localhost:*`

### 3. Testando

```bash
# Para web
flutter run -d chrome

# Verifique se não há erros no console do navegador
# F12 → Console
```

### 4. Habilitando APIs necessárias

Certifique-se de que essas APIs estão habilitadas:

- ✅ **Maps JavaScript API** (essencial para web)
- ✅ **Maps SDK for Android**
- ✅ **Maps SDK for iOS**

### 5. Configuração de Produção

Para deploy em produção, configure domínios específicos:

```
https://seu-dominio.com/*
https://www.seu-dominio.com/*
```

## Verificação

Após configurar, você deve ver:
- ✅ Mapa carregando corretamente
- ✅ Sem erros no console
- ✅ Controles de zoom funcionando
- ✅ Marcadores e áreas visíveis

## Custos

**Desenvolvimento**: Gratuito até os limites mensais
**Produção**: Configure alertas de faturamento

---

**Próximo passo**: Execute `flutter run -d chrome` e teste!