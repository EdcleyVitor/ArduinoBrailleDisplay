# Diario de Desenvolvimento - BrailleBridge
## 10 de Junho a 26 de Julho de 2026

---

### Dia 1 - 10/06 (Terca) - Pesquisa Inicial
- Pesquisa sobre ferramentas de desenvolvimento mobile
- Opcoes avaliadas: React Native, Flutter, Cordova, Ionic
- Primeira tentativa com Apache Cordova
- **FRUSTACAO**: Cordova nao suporta BLE nativamente
- Plugins BLE existentes sao instaveis e mal documentados
- Decisao: abandonar Cordova e buscar alternativa

### Dia 2 - 11/06 (Quarta) - Pesquisa Continuada
- Avaliacao de React Native com react-native-ble-plx
- Avaliacao de Flutter com flutter_blue_plus
- Flutter apresenta melhor suporte BLE e documentacao mais clara
- Decisao final: Flutter como framework do projeto

### Dia 3 - 12/06 (Quinta) - Setup do Ambiente
- Instalacao do Flutter SDK no Linux
- Configuracao do Android Studio / VS Code
- Primeiro projeto Flutter criado (hello world)
- Estudo da documentacao do flutter_blue_plus

### Dia 4 - 13/06 (Sexta) - Prototipo BLE
- Primeiro contato com a IDE do Arduino para ESP32
- Estudo do protocolo Nordic UART Service (NUS)
- Definicao dos UUIDs: Service 6e400001, Write 6e400002, Notify 6e400003
- Primeiro esboco do firmware: LED interno (GPIO 2) piscando

### Dia 5 - 14/06 (Sabado) - Firmware v1
- Firmware basico: BLE server com NUS
- Parse de padroes Braille ("100000") via BLE write
- Acendimento de 6 LEDs externos: D18, D19, D21, D25, D33, D32
- LED interno indica estado da conexao
- Layout definido: LED 0 sup.esq, LED 1 meio.esq, LED 2 inf.esq, LED 3 sup.dir, LED 4 meio.dir, LED 5 inf.dir
- Teste com ESP32 idespark + 6 LEDs no protoboard

### Dia 6 - 16/06 (Segunda) - App Flutter v1
- Projeto Flutter criado do zero
- Tela unica com caixa de texto e botao "Enviar"
- Conversor basico: a-z, 0-9 em padroes Braille
- Integracao com flutter_blue_plus
- Primeiro envio funcional: texto digitado aparece nos LEDs

### Dia 7 - 17/06 (Terca) - App v1 Completo
- Scan de dispositivos BLE
- Pre-visualizacao do padrao Braille antes de enviar
- Conexao automatica ao selecionar dispositivo
- Teste completo: digitar "oii" e ver os LEDs acenderem em sequencia

### Dia 8 - 18/06 (Quarta) - App v2 - Redesign
- Reestruturacao do codigo em multiplas telas
- Bottom Navigation Bar com 3 abas: Conectar, Enviar, Config
- Google Fonts (Poppins) para tipografia moderna
- Cards com sombra e bordas arredondadas
- Gradientes azuis nos cabecalhos
- Botao central de envio com destaque visual

### Dia 9 - 19/06 (Quinta) - App v2 Continuacao
- Tema Material 3 com cores configuraveis
- Melhoria no scan de dispositivos
- Config de velocidade na aba Config
- Primeiro APK gerado e testado no celular

### Dia 10 - 20/06 (Sexta) - App v3 - BLE Singleton
- **Bug reportado**: conexao BLE perdida ao trocar de abas
- Solucao: BLE Singleton (servico centralizado)
- Sistema de temas: Claro / Escuro / Sistema
- 6 cores de destaque: Azul, Verde, Roxo, Vermelho, Laranja, Rosa
- SharedPreferences para persistencia

### Dia 11 - 21/06 (Sabado) - App v3 Continuacao
- **Erro**: "device is not connected" ao enviar para dispositivo desconectado
- **Erro**: "write no response property not supported"
- Correcao: sendText detecta erro e atualiza estado, fallback removido
- Bluetooth check: verifica se BT esta ligado antes de escanear

### Dia 12 - 23/06 (Segunda) - Hardware Quebrado
- **PROBLEMA GRAVE**: ESP32 idespark parou de funcionar
- Porta micro USB com defeito fisico
- Decisao: usar ESP32 comum para testes
- Compra de 2x ESP32 comum + protoboard + LEDs extras

### Dia 13 - 24/06 (Terca) - Adaptacao Hardware
- Montagem do novo setup: ESP32 comum + 6 LEDs externos
- Pinagem identica ao idespark: D18, D19, D21, D25, D33, D32
- Firmware adaptado para ESP32 comum (sem OLED)

### Dia 14 - 25/06 (Quarta) - App v4 - Visual
- Splash screen animada na primeira abertura
- Logo do projeto no app
- Preview Braille com 6 pontos
- Design com cor roxa (#6C63FF) e gradientes
- **Problema**: funcionalidades BLE foram removidas acidentalmente

### Dia 15 - 26/06 (Quinta) - App v4 Contingencia
- Descoberta: v4 e apenas visual, nao funcional
- Decisao: v5 sera a uniao do design v4 com funcionalidade v3

### Dia 16 - 28/06 (Sexta) - App v5 - Uniao
- Uniao do design da v4 com toda funcionalidade da v3
- BLE Singleton restaurado
- Sistema de temas restaurado
- Conversor Braille completo restaurado
- Logo agora e icone do app em todas as densidades
- Firmware sem Serial Monitor

### Dia 17 - 30/06 (Segunda) - App v5 Testes
- Testes completos de conexao, envio, temas
- **Bug**: scan nao encontrava ESP32 as vezes
- Correcoes: scan filtra dispositivos relevantes, botao "Escanear Novamente"
- Permissoes Android 12+ corrigidas
- APK v5 gerado e validado

### Dia 18 - 01/07 (Terca) - Reorganizacao
- Reorganizacao do repositorio
- Pastas movidas para App/Desenv-Blueto/
- Versoes 1-5 organizadas individualmente
- READMEs criados para cada versao

### Dia 19 - 02/07 (Quarta) - Planejamento v6
- Decisao: migrar de shared_preferences para SQLite
- Necessidade de historico de textos enviados
- Esquema do banco: tables texts, settings, errors

### Dia 20 - 03/07 (Quinta) - App v6 - SQLite
- Migracao completa para sqflite (SQLite)
- DatabaseHelper singleton com 3 tabelas
- Historico dos ultimos 5 textos enviados
- Log de erros com timestamp

### Dia 21 - 04/07 (Sexta) - App v6 Continuacao
- Splash screen redesenhada com animacao complexa
- 6 pontos Braille piscando em sequencia (grade 2x3)
- Tela de personalizacao dedicada

### Dia 22 - 05/07 (Sabado) - App v6 Completo
- Estilo Padrao (Material3) vs Neon (dark + cor do usuario)
- Tela de informacoes do projeto
- Tela de suporte
- APK v6 gerado

### Dia 23 - 07/07 (Segunda) - Planejamento v7
- Problema: callbacks prop-drilled para gerenciar estado
- Solucao: SettingsManager singleton (ChangeNotifier)

### Dia 24 - 08/07 (Terca) - App v7 - SettingsManager
- SettingsManager implementado como ChangeNotifier
- Centraliza: tema, cores, fontes, estilo, velocidade ESP
- App reage a mudancas em tempo real

### Dia 25 - 09/07 (Quarta) - App v7 Personalizacao
- 10 fontes Google selecionaveis
- Slider de tamanho de fonte (10-24px)
- 18 cores de opcoes, preview ao vivo
- Logo atualizado para Logo2.png

### Dia 26 - 10/07 (Quinta) - App v7 Splash
- Splash screen redesenhada: 6 pontos com escala elastica
- Loading state com gradient
- APK v7 gerado

### Dia 27 - 12/07 (Sabado) - Planejamento v8
- Suporte a caracteres acentuados portugueses
- Separar teclado de letras e numeros
- Opcao de filtrar caracteres especiais

### Dia 28 - 13/07 (Domingo) - App v8 - Preferencias
- Tela de Preferencias do App
- Separador Alfabeto/Numeros
- Ignorar Acentos
- Caracteres Especiais

### Dia 29 - 14/07 (Segunda) - App v8 Braille Acentuado
- 20+ caracteres acentuados portugueses
- filterText() e stripAccents()
- Simbolo "+" adicionado ao mapa Braille

### Dia 30 - 15/07 (Terca) - App v8 Testes
- Testes de caracteres acentuados
- APK v8 gerado

### Dia 31 - 16/07 (Quarta) - Ideia Multi-Dispositivo
- Necessidade de conectar varios ESP32 simultaneamente
- Desafio: sincronizar timing entre dispositivos
- Remocao do TWS/ESP-NOW/MESH (nunca funcional)

### Dia 32 - 17/07 (Quinta) - App v9 Inicio
- Limpeza completa do codigo
- Removido: TWS, ESP-NOW, Mesh, WiFi, Sala
- SettingsManager simplificado: so conectarMultiplos

### Dia 33 - 18/07 (Sexta) - App v9 Multi-Device
- Conexao simultanea com N dispositivos
- Toggle conectarMultiplos (ativado por padrao)
- Botao "Conectar Todos": escaneia e conecta automaticamente

### Dia 34 - 19/07 (Sabado) - Sincronizacao
- **BUG GRAVE**: dispositivos nao sincronizavam
- Causa 1: race condition no @DONE
- Causa 2: BLE serializacao causava delays diferentes
- Causa 3: valores NVS diferentes em cada ESP32
- Solucao: delay fixo (espSpeed + espPause + 500ms)
- Solucao: envia @SPEED e @PAUSE antes de cada mensagem

### Dia 35 - 20/07 (Domingo) - Firmware v10
- Assinatura BLE: caracteristica 6e400004 com "WhatGodWrought1844"
- mostrarPadrao() aceita padrao novo durante exibicao
- Comandos: @SPEED, @PAUSE, @TEST, @RESET
- Disconnect bug corrigido

### Dia 36 - 21/07 (Segunda) - Testes Finais
- Teste completo com 2x ESP32 simultaneos
- Sincronizacao funcionando perfeitamente
- APK v9 gerado
- Firmware v10 salvo em ~/Downloads/ino/

### Dia 37 - 22/07 (Terca) - Code Review
- Revisao completa do codigo
- 26 problemas encontrados e corrigidos
- info_screen: limpeza de refs Mesh/WiFi/Sala
- _lastStatus bug: faltava statusSub
- file_picker removido, import morto removido

### Dia 38 - 23/07 (Quarta) - Documentacao
- READMEs criados para Versoes 6, 7, 8 e 9
- Diario de desenvolvimento criado

### Dia 39 - 24/07 (Quinta) - Push Final
- Commit da v9 no GitHub
- Commit dos READMEs

### Dia 40 - 25/07 (Sexta) - Planejamento v10
- Definicao do escopo da v10
- Mais caracteres Braille (@, #, $, %, &, =, <, >)
- Verificacao geral do sistema

### Dia 41 - 26/07 (Sabado) - Analise v10
- Levantamento de caracteres nao mapeados
- Referencia: tabela Braille internacional

---

## Resumo por Versao

| Versao | Dias | Foco Principal |
|--------|------|----------------|
| Pesquisa | 4 | Ferramentas, Cordova, setup Flutter |
| v1 | 2 | BLE basico + conversor |
| v2 | 2 | Redesign com abas |
| v3 | 2 | BLE Singleton + temas |
| Hardware | 2 | Quebra do idespark + adaptacao |
| v4 | 2 | Visual (nao funcional) |
| v5 | 2 | Uniao design + funcionalidade |
| Reorg | 1 | Repositorio |
| v6 | 4 | SQLite + splash + personalizacao |
| v7 | 4 | SettingsManager + fontes + cores |
| v8 | 4 | Preferencias + Braille acentuado |
| v9 | 6 | Multi-dispositivo + sync + assinatura |
| v10 | 2 | Mais caracteres + verificacao geral |

**Total: 41 dias**

---

## Erros e Bugs Mais Importantes

1. **Cordova nao suporta BLE** (10/06)
2. **ESP32 idespark quebrou** (23/06)
3. **v4 nao funcional** (25/06)
4. **Conexao BLE perdida** (20/06)
5. **"device is not connected"** (21/06)
6. **"write no response"** (21/06)
7. **Scan nao encontrava** (30/06)
8. **Sync multi-device** (19/07)
9. **_lastStatus vazio** (22/07)

---

## Hardware Utilizado

- 2x ESP32 comum (testes multi-device)
- 12x LEDs externos (6 por ESP32)
- Protoboards, jumpers, resistencias
- ESP32 idespark (quebrado)

---

**Autor: Edcley Vitor**
**Periodo: Junho - Julho 2026**
