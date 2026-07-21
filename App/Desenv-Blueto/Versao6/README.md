# BrailleBridge - Versao 6.0.0

## O que mudou nesta versao?

Reorganizacao completa do projeto com migracao de `shared_preferences` para **SQLite**, splash screen com animacao complexa e tela de personalizacao dedicada.

## Novidades

### SQLite como banco de dados
- **Migracao completa**: shared_preferences substituido por sqflite (SQLite)
- Tabela `texts`: historico de textos enviados (ultimos 5)
- Tabela `settings`: todas as configuracoes (tema, cor, estilo, velocidade ESP)
- Tabela `errors`: log de erros

### Splash Screen Animada
- 6 pontos Braille piscando em sequencia (grade 2x3)
- Pulso sequencial dos pontos
- Texto "BrailleBridge" com fade-in e slide

### Tela de Personalizacao
- Tema: Claro / Escuro / Sistema
- Cor de destaque: paleta de 10 cores
- Estilo do app: Padrao (Material3) / Neon (dark + cor do usuario)

### Novas telas
- `info_screen.dart`: informacoes do projeto
- `support_screen.dart`: suporte e contato
- `personalization_screen.dart`: personalizacao visual

## Arquitetura

```
lib/
├── main.dart                    # Entry + temas + primeira vez
├── database/
│   └── database_helper.dart     # Singleton SQLite
├── screens/
│   ├── splash_screen.dart       # Animacao 6 pontos
│   ├── main_screen.dart         # Container de abas
│   ├── connection_screen.dart   # Conexao BLE
│   ├── message_screen.dart      # Envio + preview
│   ├── personalization_screen.dart  # Temas e cores
│   ├── esp_config_screen.dart   # Config ESP
│   ├── settings_screen.dart     # Config geral
│   ├── info_screen.dart         # Info do projeto
│   ├── support_screen.dart      # Suporte
│   └── scan_screen.dart         # Scan BLE
├── services/
│   └── bluetooth_service.dart   # Singleton BLE
└── utils/
    └── braille_converter.dart   # Conversao texto/Braille
```

## Tecnologias

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus (singleton)
- **Fontes**: google_fonts (Poppins)
- **Persistencia**: sqflite (SQLite)
- **Links**: url_launcher
- **Compartilhar**: share_plus
- **Firmware**: Arduino C++ (ESP32 comum)
- **LEDs**: D18, D19, D21, D25, D33, D32

## Autor

**Edcley Vitor** - Desenvolvedor
**Josecley Fialho** - Orientador

Data: Julho 2026
