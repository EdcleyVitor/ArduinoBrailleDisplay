# BrailleBridge - Versão 4.0.0

## IMPORTANTE - Aviso sobre esta versão

Esta versão é **apenas uma atualização visual/estética**. Ela NÃO é funcional. Foi criada apenas para aprimorar o design do aplicativo, mas acidentalmente foram removidas várias funcionalidades que existiam na Versão 3 (conexão BLE real, sistema de temas, conversor Braille completo). **A Versão 5 será a versão completa que une o design da v4 com toda a funcionalidade da v3.**

## Status do Hardware

O ESP32 idespark (com display OLED integrado) originalmente utilizado neste projeto **sofreu uma falha na porta de compilação/micro USB**, tornando-o inutilizável para programação. O dispositivo será levado a um especialista para tentativa de recuperação. Enquanto isso, os testes estão sendo realizados com um ESP32 comum conectado a 6 LEDs.

## O que esta versão trouxe (apenas visual)

- Splash screen animada na primeira abertura
- Logo do projeto no app
- Preview Braille com 6 pontos (idêntico ao layout do ESP32)
- Design com cor roxa (#6C63FF) e gradientes
- Cards arredondados e ícones modernos

## O que foi removido (acidentalmente)

- Conexão BLE real (substituída por código falso)
- Scan de dispositivos (substituído por delay de 3 segundos)
- Sistema de temas (Claro/Escuro/Sistema)
- Seletor de cores
- Conversor Braille completo (números, maiúsculas, indicadores)
- Link para GitHub
- Dependências: permission_handler, url_launcher

## Arquitetura

```
lib/
├── main.dart                    # Entry + verificação primeira vez
├── screens/
│   ├── splash_screen.dart       # Intro animada
│   ├── main_screen.dart         # Container de abas
│   ├── connection_screen.dart   # Conexão BLE (NÃO FUNCIONAL)
│   ├── message_screen.dart      # Envio + preview 6 pontos
│   ├── settings_screen.dart     # Config (só visual)
│   └── scan_screen.dart         # Scan (NÃO FUNCIONAL)
assets/
├── logo.png                     # Logo do projeto
```

## Tecnologias

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus
- **Fontes**: google_fonts (Poppins)
- **Persistência**: shared_preferences

## Autor

**Edcley Vitor** - Desenvolvedor  
**Josecley Fialho** - Orientador

Data: Julho 2026
