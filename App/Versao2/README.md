# BrailleBridge - Versão 2.0.0

## O que mudou nesta versão?

Redesign completo da interface do aplicativo. Agora o app possui 3 abas de navegação na parte inferior, com visual moderno e profissional.

## Novidades

### Navegação por abas
- **Aba Conectar**: Tela dedicada para gerenciar a conexão Bluetooth
- **Aba Enviar**: Tela central (botão maior) para digitar e enviar mensagens
- **Aba Config**: Tela de configurações com ajustes de velocidade

### Visual profissional
- Google Fonts (Poppins) para tipografia moderna
- Cards com sombra e bordas arredondadas
- Gradientes azuis nos cabeçalhos
- Botão central de envio com destaque visual (gradiente + sombra)

### Melhorias técnicas
- Bottom Navigation Bar com design personalizado
- Tema Material 3 com cores configuráveis
- Interface responsiva e fluida

## Como funciona

1. Na aba **Conectar**, selecione o ESP32
2. Na aba **Enviar**, digite o texto e envie
3. Na aba **Config**, ajuste a velocidade de exibição

## O que foi feito

- Reestruturação do código em múltiplas telas
- Criação do componente NavigationBar personalizado
- Implementação do sistema de temas com Google Fonts
- Cards com efeitos visuais (sombra, gradiente)
- Botão central de envio com design destacado

## Problemas conhecidos

- A conexão BLE ainda é perdida ao sair da aba de conexão
- Sem opção de tema escuro
- Sem informações do projeto no app

## Tecnologias utilizadas

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus
- **Fontes**: google_fonts (Poppins)
- **Firmware**: Arduino C++ (ESP32)
- **Display**: SSD1306 OLED 0.96"

## Autor

**Edcley Vitor** - Desenvolvedor  
**Josecley Fialho** - Orientador

Data: Julho 2026
