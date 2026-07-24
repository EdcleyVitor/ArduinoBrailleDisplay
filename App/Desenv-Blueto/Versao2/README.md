# BrailleBridge - Versao 2.0.0

## O que mudou nesta versao?

Redesign completo da interface do aplicativo. Agora o app possui 3 abas de navegacao na parte inferior, com visual moderno e profissional.

## Novidades

### Navegacao por abas
- **Aba Conectar**: Tela dedicada para gerenciar a conexao Bluetooth
- **Aba Enviar**: Tela central (botao maior) para digitar e enviar mensagens
- **Aba Config**: Tela de configuracoes com ajustes de velocidade

### Visual profissional
- Google Fonts (Poppins) para tipografia moderna
- Cards com sombra e bordas arredondadas
- Gradientes azuis nos cabecalhos
- Botao central de envio com destaque visual (gradiente + sombra)

### Melhorias tecnicas
- Bottom Navigation Bar com design personalizado
- Tema Material 3 com cores configuraveis
- Interface responsiva e fluida

## Como funciona

1. Na aba **Conectar**, selecione o ESP32
2. Na aba **Enviar**, digite o texto e envie
3. Na aba **Config**, ajuste a velocidade de exibicao

## O que foi feito

- Reestruturacao do codigo em multiplas telas
- Criacao do componente NavigationBar personalizado
- Implementacao do sistema de temas com Google Fonts
- Cards com efeitos visuais (sombra, gradiente)
- Botao central de envio com design destacado

## Problemas conhecidos

- A conexao BLE ainda e perdida ao sair da aba de conexao
- Sem opcao de tema escuro
- Sem informacoes do projeto no app

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
