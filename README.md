# EPUBLIC-PROFESSOR-GUARIBAS
## 📌 Assinatura do Aplicativo  

Para assinar o aplicativo Android, é necessário gerar um **JKS (Java KeyStore)**.  

### 🔹 Gerar o arquivo JKS  
Execute o seguinte comando no terminal:  

```sh
keytool -genkeypair -v \
  -keystore guaribas.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias guaribas
```
### 📌 Configuração da Splash Screen

Para gerar a tela de abertura (splash screen), execute:
```
flutter pub run flutter_native_splash:create
```

### 📌 Configuração dos Ícones

Para criar os ícones do aplicativo, rode o seguinte comando:
```
flutter pub run flutter_launcher_icons:main
```