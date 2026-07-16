# BrailleBridge - Versão 4.0.0

## O que mudou nesta versão?

Redesign completo com foco em experiência visual. Splash screen animada, preview Braille com 6 pontos idêntico ao ESP32 e identidade visual com logo.

## Novidades

### Splash Screen Animada
- Animação fluida de 1.5 segundos com fade + scale na logo
- Transição suave para o app principal
- **Só aparece na primeira vez** que o app é aberto (controlado por SharedPreferences)
- Se o app estiver nas abas recentes, não aparece a intro

### Logo do Projeto
- Logo centralizada na splash screen
- Identidade visual consistente com o projeto

### Preview Braille com 6 Pontos
- Visualização idêntica ao display OLED do ESP32
- Layout de 2 colunas x 3 linhas com pontos animados
- Pontos acendem em tempo real conforme você digita
- Mostra a letra correspondente ao lado

### Design Profissional
- Cor principal: Roxo (#6C63FF) com gradientes suaves
- Cards com bordas arredondadas (24px) e sombras sutis
- Ícones arredondados (rounded) em toda interface
- Tipografia consistente com Poppins
- Headers com ícone + título + subtítulo descritivo
- Botões com elevação e sombras coloridas

### Configurações Renovadas
- Seções: Personalização, Dispositivo, Informações
- Slider de velocidade com tema personalizado
- Cards com ícones coloridos e bordas sutis

## Estrutura

```
lib/
├── main.dart                    # Entry + verificação primeira vez
├── screens/
│   ├── splash_screen.dart       # Intro animada
│   ├── main_screen.dart         # Container de abas
│   ├── connection_screen.dart   # Conexão BLE
│   ├── message_screen.dart      # Envio + preview 6 pontos
│   ├── settings_screen.dart     # Config
│   └── scan_screen.dart         # Scan BLE
assets/
├── logo.png                     # Logo do projeto
```

## Tecnologias

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus
- **Fontes**: google_fonts (Poppins)
- **Persistência**: shared_preferences
- **Firmware**: Arduino C++ (ESP32)
- **Display**: SSD1306 OLED 0.96"

## Autor

**Edcley Vitor** - Desenvolvedor  
**Josecley Fialho** - Orientador

Data: Julho 2026
