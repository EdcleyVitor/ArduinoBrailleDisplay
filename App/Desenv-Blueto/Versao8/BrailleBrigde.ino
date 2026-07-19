/*
  BrailleBridge v8 - ESP32 comum + 6 LEDs
  ==========================================
  Protocolo: App envia padrao Braille ("100000") direto.
  Firmware so parseia 6 chars 0/1 e acende LEDs.
  Qualquer caractere funciona (letras, numeros, acentos, simbolos).

  Layout dos 6 LEDs:
    LED 0 (D18) = superior esquerdo    LED 3 (D25) = superior direito
    LED 1 (D19) = meio esquerdo        LED 4 (D33) = meio direito
    LED 2 (D21) = inferior esquerdo    LED 5 (D32) = inferior direito

  Protocolo BLE:
    App -> ESP: @SPEED:XXXX     Delay exibicao em ms (500 a 5000)
    App -> ESP: @PAUSE:XXXX     Pausa entre letras em ms (100 a 3000)
    App -> ESP: @TEST:WAVE      Modo teste onda
    App -> ESP: @TEST:PINS      Modo teste individual
    App -> ESP: @TEST:STOP      Para teste
    App -> ESP: "100000"        Padrao Braille (6 chars 0/1)
    ESP -> App: @DONE           Padrao processado
    ESP -> App: @OK:XXX         Comando confirmado
*/

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Preferences.h>

#define BLE_SERVICE_UUID     "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_CHAR_WRITE_UUID  "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_CHAR_NOTIFY_UUID "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

#define LED_INTERNAL 2
const int ledPins[6] = {18, 19, 21, 25, 33, 32};

BLECharacteristic *bleNotifyChar = nullptr;
volatile bool bleConectado = false;
Preferences prefs;

int delayExibicao = 1500;
int delayPausa = 500;

bool testeAtivo = false;
String tipoTeste = "";
int testeStep = 0;
bool testeSubindo = true;
unsigned long testeTimer = 0;

bool padraoAtivo = false;
int padraoFase = 0;
unsigned long padraoTimer = 0;

void acenderLeds(bool padrao[6]) {
  for (int i = 0; i < 6; i++) {
    digitalWrite(ledPins[i], padrao[i] ? HIGH : LOW);
  }
}

void apagarLeds() {
  for (int i = 0; i < 6; i++) {
    digitalWrite(ledPins[i], LOW);
  }
}

bool parsePadrao(String str, bool resultado[6]) {
  if (str.length() != 6) return false;
  for (int i = 0; i < 6; i++) {
    resultado[i] = (str[i] == '1');
  }
  return true;
}

void notifyDone() {
  if (bleNotifyChar && bleConectado) {
    bleNotifyChar->setValue("@DONE");
    bleNotifyChar->notify();
  }
}

void notifyMsg(String msg) {
  if (bleNotifyChar && bleConectado) {
    bleNotifyChar->setValue(msg.c_str());
    bleNotifyChar->notify();
  }
}

void mostrarPadrao(String padrao) {
  testeAtivo = false;
  bool leds[6];
  if (parsePadrao(padrao, leds)) {
    acenderLeds(leds);
    padraoAtivo = true;
    padraoFase = 0;
    padraoTimer = millis() + delayExibicao;
  }
}

class BleServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *srv) override {
    bleConectado = true;
    digitalWrite(LED_INTERNAL, HIGH);
    testeAtivo = false;
    padraoAtivo = false;
    apagarLeds();
  }

  void onDisconnect(BLEServer *srv) override {
    bleConectado = false;
    digitalWrite(LED_INTERNAL, LOW);
    testeAtivo = false;
    padraoAtivo = false;
    apagarLeds();
    srv->getAdvertising()->start();
  }
};

class BleWriteCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *c) override {
    String valor = String(c->getValue().c_str());
    if (valor.length() == 0) return;
    if (valor.startsWith("@")) {
      processarComando(valor);
    } else {
      mostrarPadrao(valor);
    }
  }
};

void processarComando(String cmd) {
  if (cmd.startsWith("@SPEED:")) {
    String val = cmd.substring(7);
    int novoDelay = val.toInt();
    if (novoDelay >= 500 && novoDelay <= 5000) {
      delayExibicao = novoDelay;
      prefs.begin("braille", false);
      prefs.putInt("speed", delayExibicao);
      prefs.putInt("pause", delayPausa);
      prefs.end();
      notifyMsg("@OK:SPEED");
    }
  } else if (cmd.startsWith("@PAUSE:")) {
    String val = cmd.substring(7);
    int novaPausa = val.toInt();
    if (novaPausa >= 100 && novaPausa <= 3000) {
      delayPausa = novaPausa;
      prefs.begin("braille", false);
      prefs.putInt("speed", delayExibicao);
      prefs.putInt("pause", delayPausa);
      prefs.end();
      notifyMsg("@OK:PAUSE");
    }
  } else if (cmd == "@TEST:WAVE") {
    padraoAtivo = false;
    testeAtivo = true;
    tipoTeste = "WAVE";
    testeStep = 0;
    testeSubindo = true;
    testeTimer = millis();
    notifyMsg("@OK:TEST:WAVE");
  } else if (cmd == "@TEST:PINS") {
    padraoAtivo = false;
    testeAtivo = true;
    tipoTeste = "PINS";
    testeStep = 0;
    testeTimer = millis();
    notifyMsg("@OK:TEST:PINS");
  } else if (cmd == "@TEST:STOP") {
    testeAtivo = false;
    tipoTeste = "";
    apagarLeds();
    notifyMsg("@TEST:STOP:OK");
  }
}

void processarTick() {
  if (testeAtivo && bleConectado) {
    unsigned long agora = millis();

    if (tipoTeste == "WAVE") {
      if (agora - testeTimer >= 250) {
        testeTimer = agora;
        if (testeSubindo) {
          if (testeStep > 0) {
            digitalWrite(ledPins[testeStep - 1], LOW);
            digitalWrite(ledPins[testeStep - 1 + 3], LOW);
          }
          digitalWrite(ledPins[testeStep], HIGH);
          digitalWrite(ledPins[testeStep + 3], HIGH);
          testeStep++;
          if (testeStep >= 3) {
            testeSubindo = false;
            testeStep = 2;
          }
        } else {
          if (testeStep < 2) {
            digitalWrite(ledPins[testeStep + 1], LOW);
            digitalWrite(ledPins[testeStep + 1 + 3], LOW);
          }
          digitalWrite(ledPins[testeStep], HIGH);
          digitalWrite(ledPins[testeStep + 3], HIGH);
          testeStep--;
          if (testeStep < 0) {
            testeSubindo = true;
            testeStep = 0;
            apagarLeds();
          }
        }
      }
    } else if (tipoTeste == "PINS") {
      if (agora - testeTimer >= 300) {
        testeTimer = agora;
        apagarLeds();
        if (testeStep < 6) {
          digitalWrite(ledPins[testeStep], HIGH);
          testeStep++;
        } else {
          testeStep = 0;
        }
      }
    }
    return;
  }

  if (padraoAtivo && bleConectado) {
    unsigned long agora = millis();
    if (agora >= padraoTimer) {
      if (padraoFase == 0) {
        apagarLeds();
        padraoFase = 1;
        padraoTimer = agora + delayPausa;
      } else {
        padraoAtivo = false;
        notifyDone();
      }
    }
  }
}

void animacaoStartup() {
  for (int i = 0; i < 6; i++) {
    digitalWrite(ledPins[i], HIGH);
    delay(60);
  }
  for (int i = 0; i < 6; i++) {
    digitalWrite(ledPins[i], LOW);
    delay(60);
  }
  for (int i = 0; i < 6; i++) {
    digitalWrite(ledPins[i], HIGH);
    delay(100);
    digitalWrite(ledPins[i], LOW);
    delay(50);
  }
}

void iniciarBLE() {
  BLEDevice::init("BrailleBridge");
  BLEServer *server = BLEDevice::createServer();
  server->setCallbacks(new BleServerCallbacks());

  BLEService *svc = server->createService(BLE_SERVICE_UUID);

  BLECharacteristic *writeChar = svc->createCharacteristic(
    BLE_CHAR_WRITE_UUID,
    BLECharacteristic::PROPERTY_WRITE
  );
  writeChar->setCallbacks(new BleWriteCallbacks());

  bleNotifyChar = svc->createCharacteristic(
    BLE_CHAR_NOTIFY_UUID,
    BLECharacteristic::PROPERTY_NOTIFY
  );
  bleNotifyChar->addDescriptor(new BLE2902());

  svc->start();

  BLEAdvertising *adv = BLEDevice::getAdvertising();
  adv->addServiceUUID(BLE_SERVICE_UUID);
  adv->setScanResponse(true);
  adv->setMinPreferred(0x06);
  adv->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void setup() {
  delay(500);
  pinMode(LED_INTERNAL, OUTPUT);
  digitalWrite(LED_INTERNAL, LOW);

  for (int i = 0; i < 6; i++) {
    pinMode(ledPins[i], OUTPUT);
    digitalWrite(ledPins[i], LOW);
  }

  prefs.begin("braille", true);
  delayExibicao = prefs.getInt("speed", 1500);
  delayPausa = prefs.getInt("pause", 500);
  prefs.end();

  animacaoStartup();
  iniciarBLE();
}

void loop() {
  processarTick();
  delay(5);
}
