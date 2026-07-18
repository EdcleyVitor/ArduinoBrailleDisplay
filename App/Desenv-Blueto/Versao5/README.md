# BrailleBridge - Versao 5.0.0

## A versao mais completa e estavel

A Versao 5 e a **uniao do design da Versao 4 com toda a funcionalidade da Versao 3**, corrigindo os problemas de ambas. E a versao mais completa e estavel do projeto.

### Comparado as versoes anteriores

| Versao | Status |
|--------|--------|
| v1 | Basico: BLE + envio simples |
| v2 | Design: bottom nav, Google Fonts |
| v3 | Funcional: singleton BLE, temas, cores |
| v4 | Visual: splash, logo, 6 pontos (sem funcionalidade) |
| **v5** | **Completa: design + funcionalidade + correcoes** |

## Problemas detectados e corrigidos nesta versao

### 1. Desconexao silenciosa (corrigido)
**Problema:** Quando o ESP32 desconectava (bateria, fora de alcance, etc), o app nao percebia. O `_isConnected` continuava `true` e so dava erro ao tentar enviar.

**Correcao:** Adicionado listener no `device.connectionState` do flutter_blue_plus. Agora o app detecta automaticamente quando o ESP32 desconecta e atualiza o estado em todas as telas.

### 2. Erro "device is not connected" (corrigido)
**Problema:** `FlutterBluePlusException | writeCharacteristic | fbd-code 6 device is not connected` - o app tentava enviar dados para um dispositivo ja desconectado.

**Correcao:** O `sendText` agora detecta o erro de desconexao e atualiza o estado imediatamente, mostrando "Dispositivo desconectado" ao usuario.

### 3. Erro "write no response property not supported" (corrigido)
**Problema:** O `sendText` tentava primeiro com resposta, e se falhasse, tentava sem resposta. Mas a characteristic NUS so suporta write com resposta, causando erro.

**Correcao:** Removido o fallback invalido. Agora so tenta write com resposta (correto para NUS) e mostra erro claro se falhar.

### 4. Bluetooth nao encontra ESP (corrigido)
**Problema:** As vezes o scan nao encontrava o ESP32 e o usuario precisava reiniciar o Esp32.

**Correcoes:**
- Scan filtra dispositivos com nome relevante (Braille, BLE, ESP)
- Botao "Escanear Novamente" sempre visivel apos scan
- Instrucao para reiniciar o ESP32 se nao encontrado
- Barra de progresso durante o scan

### 5. Permissoes Android 12+ (corrigido)
**Problema:** App nao pedia permissoes corretas para Android 12+.

**Correcao:** `BLUETOOTH_SCAN` com `neverForLocation`, `BLUETOOTH_CONNECT`, permissoes legacy so ate SDK 30.

### 6. Logo como icone (corrigido)
**Problema:** Icone era o default do Flutter.

**Correcao:** Logo do projeto agora e o icone do app em todas as densidades.

## Firmware

```
BrailleBrigde.ino
- BLE Nordic UART Service (NUS)
- 6 LEDs externos (D18, D19, D21, D25, D33, D32)
- LED interno (GPIO 2) = indicador de conexao
- Exibicao sequencial de cada letra Braille
- Sem Serial Monitor (para menor uso de memoria)
```

### Layout dos LEDs

```
LED 0 (D18) = superior esquerdo    LED 3 (D25) = superior direito
LED 1 (D19) = meio esquerdo        LED 4 (D33) = meio direito
LED 2 (D21) = inferior esquerdo    LED 5 (D32) = inferior direito
```

## Arquitetura

```
lib/
├── main.dart                    # Entry + temas + primeira vez
├── screens/
│   ├── splash_screen.dart       # 6 pontos piscando
│   ├── main_screen.dart         # Container de abas (IndexedStack)
│   ├── connection_screen.dart   # Conexao BLE + indicador BT
│   ├── message_screen.dart      # Envio + preview 6 pontos
│   ├── settings_screen.dart     # Temas, cores, info, GitHub
│   └── scan_screen.dart         # Scan BLE com filtros
├── services/
│   └── bluetooth_service.dart   # Singleton BLE + connectionState
└── utils/
    └── braille_converter.dart   # Conversao texto/Braille
```

## Funcionalidades

### App
- **BLE Singleton**: Conexao que nao perde ao trocar de abas
- **Deteccao de desconexao**: Listener connectionState automatico
- **Scan real**: Filtra dispositivos relevantes
- **Envio real**: Texto enviado via Nordic UART Service
- **Sistema de temas**: Claro / Escuro / Sistema
- **6 cores de destaque**: Azul, Roxo, Verde, Laranja, Vermelho, Rosa
- **Conversor Braille completo**: a-z, 0-9, pontuacao
- **Configuracoes reais**: Velocidade, temas, cores, link GitHub
- **Bluetooth check**: Verifica se BT esta ligado antes de escanear

### Firmware
- **BLE Nordic UART Service**: Comunicacao com o app
- **6 LEDs externos**: Simulam a cela Braille
- **LED interno**: Indica conexao BLE
- **Sem Serial Monitor**: Menor uso de memoria

## Tecnologias

- **App**: Flutter 3.32 + Dart
- **Bluetooth**: flutter_blue_plus (singleton + connectionState)
- **Fontes**: google_fonts (Poppins)
- **Persistencia**: shared_preferences
- **Links**: url_launcher
- **Firmware**: Arduino C++ (ESP32 comum)

## Autor

**Edcley Vitor** - Desenvolvedor
**Josecley Fialho** - Orientador

Data: Julho 2026
