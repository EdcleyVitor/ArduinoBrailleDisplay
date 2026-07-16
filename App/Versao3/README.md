# BrailleBridge - Versão 3.0.0

## O que mudou nesta versão?

Versão completa e estável do aplicativo BrailleBridge. Corrige o problema de desconexão BLE, adiciona suporte a temas e reorganiza as configurações em seções lógicas.

## Novidades

### BLE Singleton (Service)
- **Correção do bug**: A conexão BLE não é mais perdida ao trocar de abas
- Serviço BLE centralizado que mantém a conexão ativa em segundo plano
- Reconexão automática quando o dispositivo está disponível

### Sistema de Temas
- 3 modos: Claro, Escuro, Sistema (segue a configuração do celular)
- 6 cores de destaque: Azul, Verde, Roxo, Vermelho, Laranja, Rosa
- Salva automaticamente com SharedPreferences
- Muda toda a interface em tempo real

### Configurações Reorganizadas
- **Personalização**: Temas e cores
- **Configurações do Dispositivo**: Velocidade + funcionalidades futuras
- **Informações**: Créditos, versão, link para GitHub

### Melhorias Visuais
- Google Fonts (Poppins) em todas as telas
- Cards com sombra e bordas arredondadas
- Gradientes nos cabeçalhos
- Bottom Navigation Bar personalizada
- Botão central de envio destacado

## Como funciona

1. Na aba **Conectar**, pare o ESP32 "BrailleBridge"
2. Na aba **Enviar**, digite o texto e envie para o display
3. Na aba **Config**, personalize o tema e as cores do app

## Arquitetura

```
lib/
├── main.dart                    # Entry point + tema
├── screens/
│   ├── main_screen.dart         # Container de abas
│   ├── connection_screen.dart   # Tela 1: Conexão
│   ├── message_screen.dart      # Tela 2: Envio
│   ├── settings_screen.dart     # Tela 3: Config
│   └── scan_screen.dart         # Diálogo de scan BLE
├── services/
│   └── bluetooth_service.dart   # Singleton BLE
└── utils/
    └── braille_converter.dart   # Conversão texto↔Braille
```

## Tecnologias utilizadas

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus (singleton)
- **Fontes**: google_fonts (Poppins)
- **Persistência**: shared_preferences
- **Links externos**: url_launcher
- **Firmware**: Arduino C++ (ESP32)
- **Display**: SSD1306 OLED 0.96"

## Autor

**Edcley Vitor** - Desenvolvedor  
**Josecley Fialho** - Orientador

Data: Julho 2026
