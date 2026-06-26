#include <Servo.h>

// PINOS
const int servoPins[6] = {3, 5, 6, 9, 10, 11};

const int buzzerPin    = 2;
const int potPin       = A0;
const int buttonPin    = 7;

// CONFIGURAÇÕES 
int anguloUp   = 90;
int anguloDown = 0;
unsigned long delayMin = 600;
unsigned long delayMax = 3000;


// MAPA BRAILLE 3,4,6,9,10,11 → (1,4)(2,5)(3,6)
const bool braille[26][6] = {
  // a     b     c     d     e     f     g     h     i     j
  {1,0, 0,0, 0,0},  // a
  {1,0, 1,0, 0,0},  // b
  {1,1, 0,0, 0,0},  // c
  {1,1, 0,1, 0,0},  // d
  {1,0, 0,1, 0,0},  // e
  {1,1, 1,0, 0,0},  // f
  {1,1, 1,1, 0,0},  // g
  {1,0, 1,1, 0,0},  // h
  {0,1, 1,0, 0,0},  // i
  {0,1, 1,1, 0,0},  // j
  {1,0, 0,0, 1,0},  // k
  {1,0, 1,0, 1,0},  // l
  {1,1, 0,0, 1,0},  // m
  {1,1, 0,1, 1,0},  // n
  {1,0, 0,1, 1,0},  // o
  {1,1, 1,0, 1,0},  // p
  {1,1, 1,1, 1,0},  // q
  {1,0, 1,1, 1,0},  // r
  {0,1, 1,0, 1,0},  // s
  {0,1, 1,1, 1,0},  // t
  {1,0, 0,0, 1,1},  // u
  {1,0, 1,0, 1,1},  // v
  {0,1, 1,1, 0,1},  // w
  {1,1, 0,0, 1,1},  // x
  {1,1, 0,1, 1,1},  // y
  {1,0, 0,1, 1,1}   // z
};

Servo servos[6];
String ultimaPalavra = "";
String palavraAtual = "";

unsigned long ultimoTempo = 0;
int letraIndex = 0;
bool exibindo = false;
unsigned long delayAtual = 1500;

void setup() {
  Serial.begin(9600);
  Serial.println("=== DISPLAY BRAILLE ===");

  for (int i = 0; i < 6; i++) {
    servos[i].attach(servoPins[i]);
    servos[i].write(anguloDown);
  }

  pinMode(buzzerPin, OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP);

  delay(1000);
}

void loop() {
  // Potenciômetro em tempo real
  int potValue = analogRead(potPin);
  delayAtual = map(potValue, 0, 1023, delayMin, delayMax);

  // Botão de repetição
  if (digitalRead(buttonPin) == LOW) {
    if (ultimaPalavra.length() > 0) {
      Serial.println("\n>>> REPETINDO: " + ultimaPalavra);
      iniciarExibicao(ultimaPalavra);
    }
    delay(300);
    while (digitalRead(buttonPin) == LOW);
  }

  // Serial
  if (Serial.available() > 0 && !exibindo) {
    String texto = Serial.readStringUntil('\n');
    texto.trim();
    texto.toLowerCase();

    if (texto.length() > 0) {
      Serial.print("Exibindo: ");
      Serial.println(texto);
      ultimaPalavra = texto;
      iniciarExibicao(texto);
    }
  }

  // Exibição
  if (exibindo) {
    if (millis() - ultimoTempo >= delayAtual) {
      ultimoTempo = millis();

      if (letraIndex < palavraAtual.length()) {
        char letraAnterior = palavraAtual[letraIndex-1];
        char letra = palavraAtual[letraIndex];

        if (letra == ' ') {
          Serial.println(" [Espaço]");
          todosParaBaixo();
          bip();
        } 
        else if (letraAnterior == letra) {
          bip();
        }
        else if (letra >= 'a' && letra <= 'z') {
          mostrarLetra(letra - 'a');
        }
        letraIndex++;
      } else {
        todosParaBaixo();
        Serial.println("\n--- Palavra finalizada ---\n");
        exibindo = false;
        letraIndex = 0;
      }
    }
  }
}

// FUNÇÕES 
void iniciarExibicao(String palavra) {
  palavraAtual = palavra;
  letraIndex = 0;
  exibindo = true;
  ultimoTempo = millis();
  todosParaBaixo();
}

void mostrarLetra(int idx) {
  Serial.print("Letra: ");
  Serial.print((char)(idx + 'a'));
  Serial.print(" → ");

  for (int p = 0; p < 6; p++) {
    bool ponto = braille[idx][p];
    int angulo = ponto ? anguloUp : anguloDown;
    servos[p].write(angulo);
    Serial.print(ponto);
    Serial.print(" ");
  }
  Serial.println();
}

void todosParaBaixo() {
  for (int i = 0; i < 6; i++) {
    servos[i].write(anguloDown);
  }
}

void bip() {
  tone(buzzerPin, 800, 120);
}
