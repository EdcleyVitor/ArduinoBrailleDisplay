# BrailleBridge - Versao 8.0.0

## O que mudou nesta versao?

Tela de **Preferencias do App** com separador alfabeto/numeros, suporte a **Braille acentuado** (20+ caracteres portugueses) e preprocessamento de texto com filtros configuraveis.

## Novidades

### Tela de Preferencias
- **Separador Alfabeto/Numeros**: divide o teclado em abas "Abc" e "123"
- **Ignorar Acentos**: remove acentos antes da conversao (a para a/á/â/ã)
- **Caracteres Especiais**: filtra caracteres nao mapeados no Braille

### Braille Acentuado
- 20+ caracteres acentuados portugueses com padroes Braille proprios
- `á`, `â`, `ã`, `é`, `ê`, `í`, `ó`, `ô`, `õ`, `ú`, `ç`, `à`, etc.
- Preprocessamento via `filterText()` e `stripAccents()`

### Novo caractere
- Simbolo `+` adicionado ao mapa Braille (`011101`)

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
│   ├── preferences_screen.dart  # Separador, acentos, especiais
│   ├── esp_config_screen.dart   # Config ESP
│   ├── settings_screen.dart     # Config geral
│   ├── info_screen.dart         # Info do projeto
│   ├── support_screen.dart      # Suporte
│   └── scan_screen.dart         # Scan BLE
├── services/
│   ├── bluetooth_service.dart   # Singleton BLE
│   └── settings_manager.dart    # Singleton Settings (ChangeNotifier)
└── utils/
    └── braille_converter.dart   # Conversao + acentos + filtros
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
