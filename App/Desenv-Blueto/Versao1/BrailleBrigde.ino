/*
  BrailleBridge — firmware BLE + OLED (v1)
  Recebe texto via BLE e desenha célula Braille na tela OLED 0.96".
  
  Bibliotecas: Adafruit SSD1306, Adafruit GFX Library
  Placa: ESP32 Dev Module
*/

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define BLE_SERVICE_UUID     "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_CHAR_WRITE_UUID  "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_CHAR_NOTIFY_UUID "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

BLECharacteristic *bleNotifyChar = nullptr;
bool bleConectado = false;

#define OLED_SDA      21
#define OLED_SCL      22
#define OLED_RESET    -1
#define SCREEN_WIDTH  128
#define SCREEN_HEIGHT 64
#define OLED_ENDERECO 0x3C

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
bool telaOk = false;

const int buzzerPin = 32;

const bool braille[26][6] = {
  {1,0, 0,0, 0,0}, {1,0, 1,0, 0,0}, {1,1, 0,0, 0,0}, {1,1, 0,1, 0,0},
  {1,0, 0,1, 0,0}, {1,1, 1,0, 0,0}, {1,1, 1,1, 0,0}, {1,0, 1,1, 0,0},
  {0,1, 1,0, 0,0}, {0,1, 1,1, 0,0}, {1,0, 0,0, 1,0}, {1,0, 1,0, 1,0},
  {1,1, 0,0, 1,0}, {1,1, 0,1, 1,0}, {1,0, 0,1, 1,0}, {1,1, 1,0, 1,0},
  {1,1, 1,1, 1,0}, {1,0, 1,1, 1,0}, {0,1, 1,0, 1,0}, {0,1, 1,1, 1,0},
  {1,0, 0,0, 1,1}, {1,0, 1,0, 1,1}, {0,1, 1,1, 0,1}, {1,1, 0,0, 1,1},
  {1,1, 0,1, 1,1}, {1,0, 0,1, 1,1}
};

String ultimaPalavra = "";
String palavraAtual  = "";
int letraIndex = 0;
bool exibindo = false;
bool faseBaixo = true;
unsigned long ultimoTempo = 0;
unsigned long delayAtual = 1500;

const int PONTO_RAIO = 8;
const int PONTO_COL_X[2] = {26, 50};
const int PONTO_LIN_Y[3] = {18, 34, 50};

class BleServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *srv) override { bleConectado = true; Serial.println("BLE: conectado"); }
  void onDisconnect(BLEServer *srv) override { bleConectado = false; Serial.println("BLE: desconectado"); srv->getAdvertising()->start(); }
};

class BleWriteCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *c) override {
    String valor = String(c->getValue().c_str());
    if (valor.length() > 0) { Serial.print("Recebido: "); Serial.println(valor); processarTexto(valor); }
  }
};

void iniciarBLE() {
  BLEDevice::init("BrailleBridge");
  BLEServer *server = BLEDevice::createServer();
  server->setCallbacks(new BleServerCallbacks());
  BLEService *svc = server->createService(BLE_SERVICE_UUID);
  BLECharacteristic *writeChar = svc->createCharacteristic(BLE_CHAR_WRITE_UUID, BLECharacteristic::PROPERTY_WRITE);
  writeChar->setCallbacks(new BleWriteCallbacks());
  bleNotifyChar = svc->createCharacteristic(BLE_CHAR_NOTIFY_UUID, BLECharacteristic::PROPERTY_NOTIFY);
  bleNotifyChar->addDescriptor(new BLE2902());
  svc->start();
  BLEAdvertising *adv = BLEDevice::getAdvertising();
  adv->addServiceUUID(BLE_SERVICE_UUID);
  adv->setScanResponse(true);
  adv->setMinPreferred(0x06);
  adv->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("BLE: BrailleBridge anunciando");
}

void processarTexto(String texto) {
  texto.trim(); texto.toLowerCase();
  if (texto.length() == 0) return;
  Serial.print("Exibindo: "); Serial.println(texto);
  ultimaPalavra = texto;
  iniciarExibicao(texto);
}

void iniciarExibicao(String palavra) {
  palavraAtual = palavra; letraIndex = 0; exibindo = true; faseBaixo = true;
  ultimoTempo = millis(); desenharCelulaVazia();
}

void atualizarExibicao() {
  if (!exibindo) return;
  if (millis() - ultimoTempo < delayAtual) return;
  ultimoTempo = millis();
  if (letraIndex < palavraAtual.length()) {
    char letra = palavraAtual[letraIndex];
    if (faseBaixo) { desenharCelulaVazia(); faseBaixo = false; }
    else {
      if (letra == ' ') { desenharEspaco(); bip(); }
      else if (letra >= 'a' && letra <= 'z') mostrarLetra(letra - 'a');
      letraIndex++; faseBaixo = true;
    }
  } else { exibindo = false; letraIndex = 0; desenharTelaOciosa(); }
}

void desenharCelula(int idx, char letraExibida) {
  if (!telaOk) return;
  display.clearDisplay();
  for (int p = 0; p < 6; p++) {
    int col = p / 3, lin = p % 3;
    int cx = PONTO_COL_X[col], cy = PONTO_LIN_Y[lin];
    bool ativo = (idx >= 0) ? braille[idx][p] : false;
    if (ativo) display.fillCircle(cx, cy, PONTO_RAIO, SSD1306_WHITE);
    else display.drawCircle(cx, cy, PONTO_RAIO, SSD1306_WHITE);
  }
  display.setTextSize(4); display.setTextColor(SSD1306_WHITE); display.setCursor(88, 24);
  if (letraExibida != 0) display.print(letraExibida);
  display.display();
}

void mostrarLetra(int idx) { desenharCelula(idx, (char)(idx + 'a')); }
void desenharCelulaVazia() { desenharCelula(-1, 0); }
void desenharEspaco() {
  if (!telaOk) return;
  display.clearDisplay(); display.setTextSize(2); display.setTextColor(SSD1306_WHITE);
  display.setCursor(20, 24); display.print("[ ESPACO ]"); display.display();
}
void desenharTelaBoasVindas() {
  if (!telaOk) return;
  display.clearDisplay(); display.setTextSize(1); display.setTextColor(SSD1306_WHITE);
  display.setCursor(16, 8); display.println("BRAILLE BRIDGE");
  display.drawLine(10, 20, 117, 20, SSD1306_WHITE);
  desenharCelula(4, 'e'); display.display();
}
void desenharTelaOciosa() {
  if (!telaOk) return;
  display.clearDisplay(); display.setTextSize(1); display.setTextColor(SSD1306_WHITE);
  display.setCursor(16, 2); display.println("BRAILLE BRIDGE");
  display.drawLine(10, 12, 117, 12, SSD1306_WHITE);
  display.setCursor(20, 20); display.println("Aguardando..."); display.display();
}
void bip() {
  for (int i = 0; i < 80; i++) {
    digitalWrite(buzzerPin, HIGH); delayMicroseconds(625);
    digitalWrite(buzzerPin, LOW); delayMicroseconds(625);
  }
}

void setup() {
  Serial.begin(115200); delay(300);
  Serial.println("\n=== BrailleBridge BLE + OLED ===");
  pinMode(buzzerPin, OUTPUT);
  Wire.begin(OLED_SDA, OLED_SCL);
  if (!display.begin(SSD1306_SWITCHCAPVCC, OLED_ENDERECO)) { Serial.println("ERRO: OLED!"); telaOk = false; }
  else { telaOk = true; display.clearDisplay(); display.setTextColor(SSD1306_WHITE); display.display(); }
  desenharTelaBoasVindas(); delay(1500);
  iniciarBLE(); desenharTelaOciosa();
  Serial.println("Pronto. Aguardando conexao BLE...");
}

void loop() { atualizarExibicao(); delay(10); }
