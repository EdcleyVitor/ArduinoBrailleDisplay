# BrailleBridge - Versao 9.0.0

## O que mudou nesta versao?

**Multi-dispositivo BLE**: conexao simultanea com multiplos ESP32, assinatura BLE para identificacao, sincronizacao de timming entre dispositivos e botao "Conectar Todos".

## Novidades

### Multi-Dispositivo
- Conexao simultanea com N dispositivos ESP32
- Toggle `conectarMultiplos` nas configuracoes (ativado por padrao)
- Envio sincronizado para todos os dispositivos conectados
- Botao "Conectar Todos": escaneia e conecta automaticamente todos os BrailleBridge

### Sincronizacao de Timming
- App envia `@SPEED` e `@PAUSE` antes de cada mensagem
- Todos os dispositivos recebem o mesmo delay antes de enviar
- Correcao do bug de race condition no `@DONE`

### Assinatura BLE
- Caracteristica `6e400004` com valor `WhatGodWrought1844`
- `verifySignature()`: valida se o dispositivo e BrailleBridge real
- Scan filtrado por UUID do servico (so mostra BrailleBridge)

### Firmware v10
- Assinatura BLE (`WhatGodWrought1844`)
- `mostrarPadrao()` aceita padrao novo durante exibicao (reseta timer)
- Comandos: `@SPEED`, `@PAUSE`, `@TEST`, `@RESET`

### Disconnect Bug Corrigido
- `_onDeviceDisconnected()` agora chama `cd.device.disconnect()`

## Arquitetura

```
lib/
├── main.dart                    # Entry + loading state
├── database/
│   └── database_helper.dart     # Singleton SQLite
├── screens/
│   ├── splash_screen.dart       # Animacao elastica
│   ├── main_screen.dart         # Container de abas
│   ├── connection_screen.dart   # Conexao BLE + "Conectar Todos"
│   ├── message_screen.dart      # Envio multi-device + preview
│   ├── personalization_screen.dart  # Fontes, cores, preview
│   ├── preferences_screen.dart  # Separador, acentos, especiais
│   ├── esp_config_screen.dart   # Config ESP
│   ├── settings_screen.dart     # Config geral
│   ├── info_screen.dart         # Info do projeto
│   ├── support_screen.dart      # Suporte
│   └── scan_screen.dart         # Scan BLE filtrado por UUID
├── services/
│   ├── bluetooth_service.dart   # Singleton BLE + multi-device + assinatura
│   └── settings_manager.dart    # Singleton Settings (ChangeNotifier)
└── utils/
    └── braille_converter.dart   # Conversao + acentos + filtros
```

## Protocolo BLE

```
App -> ESP (write):            "100000" (padrao Braille)
App -> ESP (write):            @SPEED:XXX (velocidade ms)
App -> ESP (write):            @PAUSE:XXX (pausa ms)
App -> ESP (write):            @TEST (teste LEDs)
App -> ESP (write):            @RESET (reconfigura)
App -> ESP (read):             WhatGodWrought1844 (assinatura)
ESP -> App (notify):           @DONE (padrao processado)
ESP -> App (notify):           @OK:XXX (comando confirmado)
ESP -> App (notify):           @ERRO:XXX (erro)
```

## Layout dos LEDs

```
LED 0 (D18) = superior esquerdo    LED 3 (D25) = superior direito
LED 1 (D19) = meio esquerdo        LED 4 (D33) = meio direito
LED 2 (D21) = inferior esquerdo    LED 5 (D32) = inferior direito
```

## Tecnologias

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus (multi-device)
- **Fontes**: google_fonts (10 fontes)
- **Persistencia**: sqflite (SQLite)
- **Links**: url_launcher
- **Compartilhar**: share_plus
- **Firmware**: Arduino C++ (ESP32 comum)
- **LEDs**: D18, D19, D21, D25, D33, D32

## Autor

**Edcley Vitor** - Desenvolvedor
**Josecley Fialho** - Orientador

Data: Julho 2026
