# BrailleBridge - Versao 4.0.0

## IMPORTANTE - Aviso sobre esta versao

Esta versao e **apenas uma atualizacao visual/estetica**. Ela NAO e funcional. Foi criada apenas para aprimorar o design do aplicativo, mas acidentalmente foram removidas varias funcionalidades que existiam na Versao 3 (conexao BLE real, sistema de temas, conversor Braille completo). **A Versao 5 sera a versao completa que une o design da v4 com toda a funcionalidade da v3.**

## Status do Hardware

O ESP32 idespark (com display OLED integrado) originalmente utilizado neste projeto **sofreu uma falha na porta de compilacao/micro USB**, tornando-o inutilizavel para programacao. Os testes estao sendo realizados com um ESP32 comum conectado a 6 LEDs.

## O que esta versao trouxe (apenas visual)

- Splash screen animada na primeira abertura
- Logo do projeto no app
- Preview Braille com 6 pontos (identico ao layout do ESP32)
- Design com cor roxa (#6C63FF) e gradientes
- Cards arredondados e icones modernos

## O que foi removido (acidentalmente)

- Conexao BLE real (substituida por codigo falso)
- Scan de dispositivos (substituido por delay de 3 segundos)
- Sistema de temas (Claro/Escuro/Sistema)
- Seletor de cores
- Conversor Braille completo (numeros, maiusculas, indicadores)
- Link para GitHub
- Dependencias: permission_handler, url_launcher

## Arquitetura

```
lib/
├── main.dart                    # Entry + verificacao primeira vez
├── screens/
│   ├── splash_screen.dart       # Intro animada
│   ├── main_screen.dart         # Container de abas
│   ├── connection_screen.dart   # Conexao BLE (NAO FUNCIONAL)
│   ├── message_screen.dart      # Envio + preview 6 pontos
│   ├── settings_screen.dart     # Config (so visual)
│   └── scan_screen.dart         # Scan (NAO FUNCIONAL)
assets/
├── logo.png                     # Logo do projeto
```

## Tecnologias

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus
- **Fontes**: google_fonts (Poppins)
- **Persistencia**: shared_preferences

## Autor

**Edcley Vitor** - Desenvolvedor
**Josecley Fialho** - Orientador

Data: Julho 2026
