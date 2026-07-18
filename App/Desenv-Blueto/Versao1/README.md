# BrailleBridge - Versão 1.0.0

## O que é esta versão?

Primeira versão funcional do aplicativo BrailleBridge. Esta versão establece a comunicação básica entre o app e o ESP32 via Bluetooth Low Energy (BLE).

## Funcionalidades

- **Conexão Bluetooth**: Escaneia e conecta ao ESP32 "BrailleBridge"
- **Envio de texto**: Digita um texto e envia para o display Braille
- **Pré-visualização**: Mostra o padrão Braille antes de enviar
- **Conversor**: Converte texto (a-z, 0-9) em código Braille

## Como funciona

1. Abra o app e clique em "Conectar"
2. Selecione o ESP32 "BrailleBridge" na lista
3. Digite o texto na caixa de entrada
4. Clique em "Enviar para Display"

## O que foi feito

- Configuração do projeto Flutter do zero
- Implementação do serviço BLE com Nordic UART Service (NUS)
- Criação do conversor de texto para Braille
- Interface simples com uma única tela
- Firmware ESP32 com display OLED 0.96"

## Problemas conhecidos

- Sem opções de personalização
- Interface básica sem navegação por abas

## Tecnologias utilizadas

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus
- **Firmware**: Arduino C++ (ESP32)
- **Display**: SSD1306 OLED 0.96"

## Autor

**Edcley Vitor** - Desenvolvedor  
**Josecley Fialho** - Orientador

Data: Julho 2026
