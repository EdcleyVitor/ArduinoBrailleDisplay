#include <Servo.h>  // Biblioteca que permite controlar servomotores

// ===================== PINOS =====================
const int servoPins[6] = {3, 5, 6, 9, 10, 11};  // Pinos digitais ligados aos 6 servos (pontos braille)
const int buzzerPin    = 2;   // Pino do buzzer (som de espaço entre palavras)
const int potPin       = A0;  // Pino analógico do potenciômetro (controla velocidade)
const int buttonPin    = 7;   // Pino do botão (repetir última palavra)

// ===================== CONFIGURAÇÕES =====================
int anguloUp   = 90;   // Ângulo do servo quando o ponto braille está "levantado"
int anguloDown = 0;    // Ângulo do servo quando o ponto braille está "abaixado"
unsigned long delayMin = 600;   // Menor tempo possível entre fases (exibição rápida)
unsigned long delayMax = 3000;  // Maior tempo possível entre fases (exibição lenta)

// ===================== MAPA BRAILLE =====================
// Cada linha representa uma letra de 'a' a 'z'.
// Cada coluna representa um dos 6 pontos do braille (1 = levantado, 0 = abaixado)
// Ordem dos pontos: (1,4)(2,5)(3,6) conforme os pinos 3,4,6,9,10,11
const bool braille[26][6] = {
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

// ===================== OBJETOS E VARIÁVEIS GLOBAIS =====================
Servo servos[6];  // Array de objetos Servo, um pra cada ponto braille

String ultimaPalavra = "";  // Guarda a última palavra exibida (pro botão repetir)
String palavraAtual  = "";  // Palavra sendo exibida no momento

unsigned long ultimoTempo = 0;   // Registra o millis() da última troca de fase
int  letraIndex = 0;             // Índice da letra atual dentro de palavraAtual
bool exibindo   = false;         // true = uma exibição está em andamento
bool faseBaixo  = true;          // true = próxima ação é abaixar; false = próxima ação é mostrar letra
unsigned long delayAtual = 1500; // Tempo atual entre fases, definido pelo potenciômetro

// ================================================================
// setup(): roda uma vez quando o Arduino liga/reinicia
// ================================================================
void setup() {
  Serial.begin(9600);              // Inicia comunicação serial a 9600 bps
  Serial.println("=== DISPLAY BRAILLE ===");  // Mensagem inicial no Monitor Serial

  // Anexa cada servo ao seu pino e já deixa todos na posição "abaixado"
  for (int i = 0; i < 6; i++) {
    servos[i].attach(servoPins[i]);
    servos[i].write(anguloDown);
  }

  pinMode(buzzerPin, OUTPUT);       // Buzzer é saída digital
  pinMode(buttonPin, INPUT_PULLUP); // Botão usa resistor de pull-up interno (LOW = pressionado)

  delay(1000);  // Pequena pausa pra estabilizar os servos antes de começar
}

// ================================================================
// loop(): roda continuamente, para sempre, enquanto o Arduino estiver ligado
// ================================================================
void loop() {

  // ---------- LEITURA DO POTENCIÔMETRO (velocidade em tempo real) ----------
  int potValue = analogRead(potPin);  // Lê valor de 0 a 1023 do potenciômetro
  delayAtual = map(potValue, 0, 1023, delayMin, delayMax);  // Converte pra faixa 600-3000ms

  // ---------- BOTÃO DE REPETIÇÃO ----------
  if (digitalRead(buttonPin) == LOW) {  // Botão pressionado (LOW por causa do pull-up)
    if (ultimaPalavra.length() > 0) {   // Só repete se já existir uma palavra guardada
      Serial.println("\n>>> REPETINDO: " + ultimaPalavra);
      iniciarExibicao(ultimaPalavra);   // Reinicia a máquina de estados com a última palavra
    }
    delay(300);                          // Pequeno atraso pra evitar leituras duplicadas (debounce)
    while (digitalRead(buttonPin) == LOW); // Trava aqui até o usuário soltar o botão
  }

  // ---------- LEITURA DA PORTA SERIAL ----------
  if (Serial.available() > 0 && !exibindo) {  // Só lê se tiver dado disponível e nada sendo exibido
    String texto = Serial.readStringUntil('\n');  // Lê até encontrar o Enter (\n)
    texto.trim();          // Remove espaços/quebras de linha extras
    texto.toLowerCase();   // Converte tudo pra minúsculo (a matriz braille só tem a-z)

    if (texto.length() > 0) {  // Se sobrou algum texto válido
      Serial.print("Exibindo: ");
      Serial.println(texto);
      ultimaPalavra = texto;     // Guarda pra possível repetição futura
      iniciarExibicao(texto);    // Começa a exibir a nova palavra
    }
  }

  // ---------- MÁQUINA DE ESTADOS DA EXIBIÇÃO ----------
  if (exibindo) {  // Só executa se uma exibição estiver ativa
    if (millis() - ultimoTempo >= delayAtual) {  // Verifica se já passou tempo suficiente (sem usar delay())
      ultimoTempo = millis();  // Reinicia a contagem de tempo

      if (letraIndex < palavraAtual.length()) {  // Ainda existem letras a processar
        char letra = palavraAtual[letraIndex];   // Pega a letra atual da palavra

        if (faseBaixo) {
          // FASE 1: abaixa todos os servos antes de mostrar a próxima letra
          // Isso garante que letras repetidas (ex: "ll") realmente desçam e subam de novo
          todosParaBaixo();
          faseBaixo = false;  // Próximo ciclo será a fase de "mostrar"
        } else {
          // FASE 2: mostra a letra atual (ou toca o beep se for espaço)
          if (letra == ' ') {
            Serial.println(" [Espaço]");
            bip();  // Som indicando fim de uma palavra / início de outra
          } else if (letra >= 'a' && letra <= 'z') {
            mostrarLetra(letra - 'a');  // Converte char pra índice 0-25 e exibe
          }
          letraIndex++;      // Avança para a próxima letra da palavra
          faseBaixo = true;  // Próximo ciclo volta a ser a fase de "abaixar"
        }
      } else {
        // Não há mais letras: encerra a exibição
        todosParaBaixo();
        Serial.println("\n--- Palavra finalizada ---\n");
        exibindo = false;   // Libera o sistema pra aceitar nova palavra
        letraIndex = 0;     // Reseta o índice pra próxima vez
      }
    }
  }
}

// ================================================================
// FUNÇÕES AUXILIARES
// ================================================================

// iniciarExibicao(): prepara a máquina de estados para exibir uma nova palavra do zero
void iniciarExibicao(String palavra) {
  palavraAtual = palavra;   // Define qual palavra será exibida
  letraIndex = 0;           // Começa da primeira letra
  exibindo = true;          // Ativa o processo de exibição
  faseBaixo = true;         // Começa sempre abaixando os servos primeiro
  ultimoTempo = millis();   // Marca o instante inicial pra contagem de tempo
  todosParaBaixo();         // Garante que tudo comece na posição de repouso
}

// mostrarLetra(): levanta os servos correspondentes ao padrão braille da letra
// idx vai de 0 ('a') a 25 ('z')
void mostrarLetra(int idx) {
  Serial.print("Letra: ");
  Serial.print((char)(idx + 'a'));  // Converte o índice de volta pro caractere original
  Serial.print(" → ");

  for (int p = 0; p < 6; p++) {           // Percorre os 6 pontos do braille
    bool ponto = braille[idx][p];         // Pega se esse ponto deve subir (1) ou não (0)
    int angulo = ponto ? anguloUp : anguloDown;  // Escolhe o ângulo correspondente
    servos[p].write(angulo);              // Move o servo pra esse ângulo
    Serial.print(ponto);
    Serial.print(" ");
  }
  Serial.println();
}

// todosParaBaixo(): move todos os 6 servos para a posição de repouso (abaixado)
void todosParaBaixo() {
  for (int i = 0; i < 6; i++) {
    servos[i].write(anguloDown);
  }
}

// bip(): emite um som curto no buzzer (usado apenas para indicar espaço entre palavras)
void bip() {
  tone(buzzerPin, 800, 120);  // Toca 800Hz por 120 milissegundos
}
