# 🛠️ Ferramentas Utilizadas no Teste

Este aplicativo foi construído utilizando o ecossistema do **React Native** gerenciado pelo **Expo**. Abaixo está a explicação simples de como essas tecnologias funcionam juntas para dar vida ao aplicativo.

---

## 📱 React Native
O **React Native** é o framework de desenvolvimento (criado pela Meta/Facebook) que permite escrever o aplicativo utilizando apenas **JavaScript** e **React**. 

* **Como funciona:** Em vez de programar duas vezes (uma em Kotlin/Java para Android e outra em Swift para iOS), escrevemos um único código. O React Native se encarrega de traduzir esse código em componentes nativos e reais do sistema operacional do celular.

---

## 🚀 Expo
O **Expo** é a plataforma principal que gerencia e facilita todo o desenvolvimento com o React Native. 

Sem o Expo, seria necessário instalar o Android Studio, configurar emuladores pesados e mexer em pastas nativas complexas do Android. O Expo resolve isso funcionando como um facilitador:
* **Acesso Simplificado ao Hardware:** Ele fornece APIs prontas para acessar recursos físicos como o Bluetooth Low Energy (BLE), internet e permissões de forma simples.
* **Configuração Inteligente:** Toda a configuração de ícones, telas de inicialização e permissões do Android é feita de forma declarativa dentro de um arquivo simples chamado `app.json`.
* **Gerenciamento Automático:** Ele cria e mantém as pastas nativas do Android em segundo plano de forma totalmente silenciosa.

---

## 📦 EAS Build (Expo Application Services)
Para gerar o arquivo instalável (`.apk`) do aplicativo de forma rápida e sem consumir os recursos do computador local, utilizamos o **EAS Build**.

* **Compilação na Nuvem:** Quando enviamos o comando de build, o nosso código do projeto (que é super leve) é enviado para os servidores dedicados da Expo.
* **Geração do APK:** Os servidores da Expo realizam toda a compilação pesada do Android SDK na nuvem e geram um link de download direto com um QR Code para instalar o aplicativo no celular de forma 100% sem fio.
