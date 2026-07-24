# BrailleBridge - Versao 3.0.0

## O que mudou nesta versao?

Versao completa e estavel do aplicativo BrailleBridge. Corrige o problema de desconexao BLE, adiciona suporte a temas e reorganiza as configuracoes em secoes logicas.

## Status do Hardware

O ESP32 idespark (com display OLED integrado) originalmente utilizado neste projeto **sofreu uma falha na porta de compilacao/micro USB**, tornando-o inutilizavel para programacao. Os testes estao sendo realizados com um ESP32 comum.

## Novidades

### BLE Singleton (Service)
- **Correcao do bug**: A conexao BLE nao e mais perdida ao trocar de abas
- Servico BLE centralizado que mantem a conexao ativa em segundo plano
- Reconexao automatica quando o dispositivo esta disponivel

### Sistema de Temas
- 3 modos: Claro, Escuro, Sistema (segue a configuracao do celular)
- 6 cores de destaque: Azul, Verde, Roxo, Vermelho, Laranja, Rosa
- Salva automaticamente com SharedPreferences
- Muda toda a interface em tempo real

### Configuracoes Reorganizadas
- **Personalizacao**: Temas e cores
- **Configuracoes do Dispositivo**: Velocidade + funcionalidades futuras
- **Informacoes**: Creditos, versao, link para GitHub

### Melhorias Visuais
- Google Fonts (Poppins) em todas as telas
- Cards com sombra e bordas arredondadas
- Gradientes nos cabecalhos
- Bottom Navigation Bar personalizada
- Botao central de envio destacado

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
│   ├── connection_screen.dart   # Tela 1: Conexao
│   ├── message_screen.dart      # Tela 2: Envio
│   ├── settings_screen.dart     # Tela 3: Config
│   └── scan_screen.dart         # Dialogo de scan BLE
├── services/
│   └── bluetooth_service.dart   # Singleton BLE
└── utils/
    └── braille_converter.dart   # Conversao texto/Braille
```

## Tecnologias utilizadas

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus (singleton)
- **Fontes**: google_fonts (Poppins)
- **Persistencia**: shared_preferences
- **Links externos**: url_launcher
- **Firmware**: Arduino C++ (ESP32)
- **Display**: SSD1306 OLED 0.96"

## Autor

**Edcley Vitor** - Desenvolvedor
**Josecley Fialho** - Orientador

Data: Julho 2026
