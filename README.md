# ArduinoBrailleDisplay

# ⠃⠗⠁⠊⠇⠇⠑ • Protótipo de Display Braille Automatizado com Arduino

> **Apoio à acessibilidade de pessoas com deficiência visual através da cultura maker.**

[cite_start]Este repositório contém o código-fonte, esquemas de circuitos e documentação para o desenvolvimento de um protótipo funcional e de baixo custo de uma célula de exibição Braille atualizável[cite: 25, 30, 43]. [cite_start]O projeto foi idealizado como uma pesquisa de iniciação científica voltada para a criação de tecnologias assistivas acessíveis[cite: 30, 44, 47].

---

## 📋 Sumário
- [Sobre o Projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Componentes Utilizados](#-componentes-utilizados)
- [Arquitetura do Circuito](#-arquitetura-do-circuito)
- [Estrutura do Repositório](#-estrutura-do-repositório)
- [Como Executar](#-como-executar)
- [Cronograma de Desenvolvimento](#-cronograma-de-desenvolvimento)
- [Autores e Vinculação](#-autores-e-vinculação)

---

## 🚀 Sobre o Projeto

[cite_start]Muitos dispositivos eletrônicos voltados para a leitura tátil em Braille possuem custo elevado, dificultando o acesso em escolas e espaços de formação[cite: 40]. [cite_start]Diante disso, este projeto investiga uma alternativa baseada na cultura maker e no pensamento computacional para criar um display automatizado utilizando componentes eletrônicos acessíveis[cite: 20, 28, 43]. 

[cite_start]O objetivo principal é montar e programar uma célula Braille de 6 pontos móveis acionados por solenoides, permitindo a representação tátil de caracteres alfanuméricos simples[cite: 26, 31, 32].


---

## ✨ Funcionalidades

* [cite_start]**Exibição Tátil Dinâmica:** Acionamento individual de 6 pontos organizados em uma matriz de 3 linhas e 2 colunas[cite: 26, 49].
* [cite_start]**Controle por Botão:** Interface simplificada para alternar ou controlar a leitura de caracteres[cite: 25, 33].
* [cite_start]**Segurança Elétrica:** Circuito projetado com isolamento de corrente e aterramento comum para evitar sobrecargas[cite: 36, 51].
* [cite_start]**Estrutura Adaptável:** Base projetada para acomodar e estabilizar os solenoides, otimizando o toque[cite: 27, 34].

---

## 🛠️ Componentes Utilizados

| Quantidade | Componente | Função no Circuito |
| :---: | :--- | :--- |
| 1 | **Arduino (Uno/Nano)** | [cite_start]Microcontrolador principal responsável pela lógica e processamento[cite: 25, 48]. |
| 6 | **Solenoides** | [cite_start]Atuadores eletromecânicos que elevam os pontos táteis da célula[cite: 26, 31]. |
| 6 | **Transistores MOSFET** | [cite_start]Chaveamento de potência para acionar os solenoides com segurança[cite: 25, 33]. |
| 6 | **Diodos de Proteção** | [cite_start]Proteção contra picos de tensão reversa induzidos pelos solenoides[cite: 25, 33]. |
| 1 | **Fonte Externa de 12V** | [cite_start]Alimentação exclusiva para a bobina dos solenoides[cite: 25, 51]. |
| 1 | **Botão de Controle** | [cite_start]Interação direta com o usuário para comandar o protótipo[cite: 25, 33]. |
| - | **Resistores e Protoboard** | [cite_start]Estruturação das conexões e limitação de corrente[cite: 48]. |

---

## ⚡ Arquitetura do Circuito

O circuito adota uma separação estrita de energia para proteger os pinos lógicos do Arduino:
* [cite_start]**Circuito de Controle:** Opera em 5V fornecidos pelo Arduino[cite: 51].
* [cite_start]**Circuito de Potência:** Opera em 12V alimentado pela fonte externa, acionando os solenoides através dos MOSFETs[cite: 51].
* [cite_start]**Ponto Comum:** Ambos os circuitos compartilham o mesmo pino de aterramento (GND) para referência de sinal[cite: 51].


---

## 📂 Estrutura do Repositório

* [cite_start]`/src`: Arquivos de código-fonte (`.ino`) para gravação no Arduino[cite: 53].
* `/hardware`: Esquemas elétricos e diagramas de conexões.
* [cite_start]`/cad`: Modelos 3D ou desenhos da estrutura física do display[cite: 54].
* [cite_start]`/docs`: Plano de pesquisa e anotações do Diário de Bordo[cite: 3, 55].

---

## 💻 Como Executar

### Pré-requisitos
* [cite_start]Ter a [Arduino IDE](https://www.arduino.cc/en/software) instalada[cite: 69].
* [cite_start]Montar o circuito seguindo as especificações de isolamento 5V/12V descritas na documentação[cite: 51].

### Passo a Passo
1. Clone este repositório:
   ```bash
   git clone [https://github.com/seu-usuario/nome-do-repositorio.git](https://github.com/seu-usuario/nome-do-repositorio.git)
