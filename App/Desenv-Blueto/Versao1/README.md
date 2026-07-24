# BrailleBridge - Versao 1.0.0

## O que e esta versao?

Primeira versao funcional do aplicativo BrailleBridge. Esta versao estabelece a comunicacao basica entre o app e o ESP32 via Bluetooth Low Energy (BLE).

## Funcionalidades

- **Conexao Bluetooth**: Escaneia e conecta ao ESP32 "BrailleBridge"
- **Envio de texto**: Digita um texto e envia para o display Braille
- **Pre-visualizacao**: Mostra o padrao Braille antes de enviar
- **Conversor**: Converte texto (a-z, 0-9) em codigo Braille

## Como funciona

1. Abra o app e clique em "Conectar"
2. Selecione o ESP32 "BrailleBridge" na lista
3. Digite o texto na caixa de entrada
4. Clique em "Enviar para Display"

## O que foi feito

- Configuracao do projeto Flutter do zero
- Implementacao do servico BLE com Nordic UART Service (NUS)
- Criacao do conversor de texto para Braille
- Interface simples com uma unica tela
- Firmware ESP32 com display OLED 0.96"

## Problemas conhecidos

- Sem opcoes de personalizacao
- Interface basica sem navegacao por abas

## Tecnologias utilizadas

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus
- **Firmware**: Arduino C++ (ESP32)
- **Display**: SSD1306 OLED 0.96"

## Autor

**Edcley Vitor** - Desenvolvedor
**Josecley Fialho** - Orientador

Data: Julho 2026
