/*
  BrailleBridge v5 - ESP32 comum + 6 LEDs
  ==========================================
  
  Motivo da mudanca: O ESP32 idespark original (com OLED integrado) sofreu
  uma falha na porta micro USB / compilacao e ficou inutilizavel para
  programacao. Enquanto aguarda recuperacao, esta versao usa um ESP32
  comum com 6 LEDs externos para simular a cela Braille.
  
  LED interno (GPIO 2): acende quando o celular conecta via BLE
  LED interno apaga: quando o celular desconecta
  
  Layout dos 6 LEDs (mesma posicao da cela Braille):
    LED 0 (D18) = superior esquerdo    LED 3 (D25) = superior direito
    LED 1 (D19) = meio esquerdo        LED 4 (D33) = meio direito
    LED 2 (D21) = inferior esquerdo    LED 5 (D32) = inferior direito
  
  Bibliotecas necessarias: nenhuma extra (usa BLE nativo do ESP32)
  Placa: ESP32 Dev Module
*/

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define BLE_SERVICE_UUID     "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_CHAR_WRITE_UUID  "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_CHAR_NOTIFY_UUID "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

#define LED_INTERNAL 2

const int ledPins[6] = {18, 19, 21, 25, 33, 32};

BLECharacteristic *bleNotifyChar = nullptr;
bool bleConectado = false;

const bool braille[26][6] = {
  {1,0,0,0,0,0}, {1,1,0,0,0,0}, {1,0,0,1,0,0}, {1,0,0,1,1,0},
  {1,0,0,0,1,0}, {1,1,0,1,0,0}, {1,1,0,1,1,0}, {1,1,0,0,1,0},
  {0,1,0,1,0,0}, {0,1,0,1,1,0}, {1,0,1,0,0,0}, {1,1,1,0,0,0},
  {1,0,1,1,0,0}, {1,0,1,1,1,0}, {1,0,1,0,1,0}, {1,1,1,1,0,0},
  {1,1,1,1,1,0}, {1,1,1,0,1,0}, {0,1,1,1,0,0}, {0,1,1,1,1,0},
  {1,0,1,0,0,1}, {1,1,1,0,0,1}, {0,1,0,1,1,1}, {1,0,1,1,0,1},
  {1,0,1,1,1,1}, {1,0,1,0,1,1}
};

void apagarLeds();
void processarTexto(String texto);

class BleServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *srv) override {
    bleConectado = true;
    digitalWrite(LED_INTERNAL, HIGH);
  }

  void onDisconnect(BLEServer *srv) override {
    bleConectado = false;
    digitalWrite(LED_INTERNAL, LOW);
    apagarLeds();
    srv->getAdvertising()->start();
  }
};

class BleWriteCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *c) override {
    String valor = String(c->getValue().c_str());
    if (valor.length() > 0) {
      processarTexto(valor);
    }
  }
};

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

void acenderTodos() {
  for (int i = 0; i < 6; i++) {
    digitalWrite(ledPins[i], HIGH);
  }
}

void processarTexto(String texto) {
  texto.trim();
  texto.toLowerCase();
  if (texto.length() == 0) return;

  for (int i = 0; i < texto.length(); i++) {
    char letra = texto[i];

    if (letra == ' ') {
      apagarLeds();
      delay(1500);
      continue;
    }

    if (letra >= 'a' && letra <= 'z') {
      int idx = letra - 'a';
      bool padrao[6];
      for (int j = 0; j < 6; j++) {
        padrao[j] = braille[idx][j];
      }
      acenderLeds(padrao);
      delay(1500);
      apagarLeds();
      delay(300);
    }
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

void setup() {
  delay(500);

  pinMode(LED_INTERNAL, OUTPUT);
  digitalWrite(LED_INTERNAL, LOW);

  for (int i = 0; i < 6; i++) {
    pinMode(ledPins[i], OUTPUT);
    digitalWrite(ledPins[i], LOW);
  }

  animacaoStartup();

  iniciarBLE();
}

void loop() {
  delay(100);
}
