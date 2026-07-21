# BrailleBridge - Versao 7.0.0

## O que mudou nesta versao?

**SettingsManager singleton (ChangeNotifier)** que centraliza todo o estado do app, personalizacao visual total com 10 fontes, 18 cores, preview ao vivo e splash screen redesenhada.

## Novidades

### SettingsManager (ChangeNotifier)
- Substitui o sistema de callbacks prop-drilled da v6
- Singleton centralizado que todas as telas acessam via `addListener`
- Gerencia: tema, cores, fontes, estilo, velocidade ESP, preferencias

### Personalizacao Total
- **10 fontes Google**: Poppins, Roboto, Lato, Montserrat, Open Sans, Raleway, Nunito, Quicksand, Inter, DM Sans
- **Slider de tamanho**: 10-24px
- **Cores**: cor primaria, secundaria, seed (18 opcoes), cor texto primaria, cor texto secundaria
- **Preview ao vivo**: mostra como tudo fica junto no final da tela

### Splash Screen Redesenhada
- 6 pontos aparecem com escala elastica
- Alinham em linha horizontal
- Texto "BrailleBridge" com fade-in

### Logo Atualizado
- De `assets/logo.png` para `assets/Logo2.png`

## Arquitetura

```
lib/
├── main.dart                    # Entry + loading state
├── database/
│   └── database_helper.dart     # Singleton SQLite
├── screens/
│   ├── splash_screen.dart       # Animacao elastica
│   ├── main_screen.dart         # Container de abas
│   ├── connection_screen.dart   # Conexao BLE
│   ├── message_screen.dart      # Envio + preview
│   ├── personalization_screen.dart  # Fontes, cores, preview
│   ├── esp_config_screen.dart   # Config ESP
│   ├── settings_screen.dart     # Config geral
│   ├── info_screen.dart         # Info do projeto
│   ├── support_screen.dart      # Suporte
│   └── scan_screen.dart         # Scan BLE
├── services/
│   ├── bluetooth_service.dart   # Singleton BLE
│   └── settings_manager.dart    # Singleton Settings (ChangeNotifier)
└── utils/
    └── braille_converter.dart   # Conversao texto/Braille
```

## Tecnologias

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus (singleton)
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
