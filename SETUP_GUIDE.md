# 📱 Guia de Implementação - Drone Flight Planner

## 🚀 Passo 1: Preparar o Ambiente

### Requisitos
- **Flutter SDK** 3.0+
- **Android SDK** (API 29+)
- **Android Studio**
- **Git**
- Chave de API do **DJI Developer**
- Chave de API do **Google Maps** (opcional para versão final)

### Instalação do Flutter

1. Baixe em: https://flutter.dev/docs/get-started/install
2. Descompacte e adicione ao PATH:
   ```bash
   export PATH="$PATH:/caminho/para/flutter/bin"
   ```
3. Verifique a instalação:
   ```bash
   flutter doctor
   ```

---

## 📋 Passo 2: Configurar Projeto

### Clone o repositório
```bash
git clone https://github.com/Lorenzo32/DroneFlightPlanner.git
cd DroneFlightPlanner
```

### Instale as dependências
```bash
flutter pub get
```

---

## 🔑 Passo 3: Configurar DJI SDK

### 3.1 Registre seu App no DJI Developer Portal

1. Acesse: https://developer.dji.com
2. Crie uma conta (se não tiver)
3. Vá em **My Apps** → **Create App**
4. Preencha:
   - **App Name**: `DroneFlightPlanner`
   - **App Package Name**: `com.droneflanner.app`
   - **Platform**: Android
   - **Category**: Mapping
5. Pegue a **API Key** gerada

### 3.2 Configure o AndroidManifest.xml

Edite: `android/app/src/main/AndroidManifest.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.droneflanner.app">

    <!-- Permissões DJI -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <application
        android:label="Drone Flight Planner"
        android:icon="@mipmap/ic_launcher">

        <!-- Atividade Flutter -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Metadados DJI -->
        <meta-data
            android:name="dji_sdk_key"
            android:value="SEU_DJI_API_KEY_AQUI" />

    </application>

</manifest>
```

**Substitua `SEU_DJI_API_KEY_AQUI` pela chave obtida no portal DJI.**

### 3.3 Configure build.gradle

Edite: `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.droneflanner.app"
        minSdkVersion 29
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildFeatures {
        ndkBuild true
    }
}

dependencies {
    // DJI Mobile SDK
    implementation 'com.dji:dji-sdk:1.19.1'
}
```

---

## 📍 Passo 4: Configurar Google Maps (Opcional)

### 4.1 Gere SHA-1 do seu certificado

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copie o **SHA1**

### 4.2 Crie chave Google Maps

1. Acesse: https://console.cloud.google.com
2. Crie um novo projeto
3. Ative **Maps SDK for Android**
4. Vá em **Credentials** → **Create Credentials** → **API Key**
5. Restrinja para Android com o SHA1

### 4.3 Adicione a chave no AndroidManifest.xml

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="SUA_CHAVE_GOOGLE_MAPS_AQUI" />
```

---

## 💻 Passo 5: Implementar Code Native (Kotlin)

### 5.1 Crie o arquivo MainActivity.kt

Edite ou crie: `android/app/src/main/kotlin/com/droneflanner/MainActivity.kt`

```kotlin
package com.droneflanner.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import dji.sdk.mobile.SDKManager
import dji.ux.widget.core.util.SettingDefinitions

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.droneplanner/dji"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeDJI" -> initializeDJI(result)
                "getDroneStatus" -> getDroneStatus(result)
                "startMission" -> startMission(call.argument<List<Map<String, Any>>>("waypoints"), result)
                "pauseMission" -> pauseMission(result)
                "resumeMission" -> resumeMission(result)
                "stopMission" -> stopMission(result)
                "goHome" -> goHome(result)
                "setHomeLocation" -> {
                    val lat = call.argument<Double>("latitude") ?: 0.0
                    val lng = call.argument<Double>("longitude") ?: 0.0
                    setHomeLocation(lat, lng, result)
                }
                "setGimbalAngle" -> {
                    val angle = call.argument<Double>("angle") ?: 0.0
                    setGimbalAngle(angle, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeDJI(result: MethodChannel.Result) {
        try {
            // Inicializar DJI SDK
            SDKManager.getInstance().initSDKManager(this, object : SDKManager.SDKManagerCallback {
                override fun onRegister() {
                    runOnUiThread {
                        result.success("DJI SDK registrado com sucesso")
                    }
                }

                override fun onDiagnose(diagnostics: String) {
                    android.util.Log.d("DJI_DEBUG", diagnostics)
                }

                override fun onDestroy() {
                    android.util.Log.d("DJI_DEBUG", "DJI SDK destruído")
                }
            })
        } catch (e: Exception) {
            result.error("DJI_INIT_ERROR", e.message, null)
        }
    }

    private fun getDroneStatus(result: MethodChannel.Result) {
        try {
            val statusMap = mapOf(
                "battery" to 85.0,  // Simulado - será implementado com SDK real
                "satellites" to 12,
                "signalStrength" to 80.0,
                "altitude" to 0.0,
                "speed" to 0.0,
                "homeDistance" to 0.0,
                "isFlying" to false
            )
            result.success(statusMap)
        } catch (e: Exception) {
            result.error("STATUS_ERROR", e.message, null)
        }
    }

    private fun startMission(waypoints: List<Map<String, Any>>?, result: MethodChannel.Result) {
        try {
            if (waypoints != null) {
                // Implementar lógica de start mission com DJI SDK
                android.util.Log.d("DJI_MISSION", "Iniciando missão com ${waypoints.size} waypoints")
                result.success(true)
            } else {
                result.error("INVALID_WAYPOINTS", "Waypoints inválidos", null)
            }
        } catch (e: Exception) {
            result.error("MISSION_ERROR", e.message, null)
        }
    }

    private fun pauseMission(result: MethodChannel.Result) {
        try {
            // Implementar pausa da missão
            result.success(true)
        } catch (e: Exception) {
            result.error("PAUSE_ERROR", e.message, null)
        }
    }

    private fun resumeMission(result: MethodChannel.Result) {
        try {
            // Implementar retomada da missão
            result.success(true)
        } catch (e: Exception) {
            result.error("RESUME_ERROR", e.message, null)
        }
    }

    private fun stopMission(result: MethodChannel.Result) {
        try {
            // Implementar parada da missão
            result.success(true)
        } catch (e: Exception) {
            result.error("STOP_ERROR", e.message, null)
        }
    }

    private fun goHome(result: MethodChannel.Result) {
        try {
            // Implementar retorno para casa
            result.success(true)
        } catch (e: Exception) {
            result.error("HOME_ERROR", e.message, null)
        }
    }

    private fun setHomeLocation(latitude: Double, longitude: Double, result: MethodChannel.Result) {
        try {
            // Implementar definição do local de decolagem
            result.success(true)
        } catch (e: Exception) {
            result.error("HOME_LOCATION_ERROR", e.message, null)
        }
    }

    private fun setGimbalAngle(angle: Double, result: MethodChannel.Result) {
        try {
            // Implementar ajuste do gimbal
            result.success(true)
        } catch (e: Exception) {
            result.error("GIMBAL_ERROR", e.message, null)
        }
    }
}
```

---

## 📱 Passo 6: Rodar no Celular

### 6.1 Conecte seu Android ao PC

```bash
# Ative modo desenvolvedor no celular
# Configurações → Sobre o telefone → Número de compilação (7 vezes)
# Voltapaçar → Opções do desenvolvedor → Ativar depuração USB

# Liste dispositivos
flutter devices
```

### 6.2 Execute o app

```bash
flutter run
```

Ou, para escolher o dispositivo específico:

```bash
flutter run -d <device_id>
```

### 6.3 Compile para Release (quando quiser distribuir)

```bash
flutter build apk --release
```

A APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

---

## ⚙️ Passo 7: Conectar Controle do Drone

1. **Ligue o controle remoto do DJI Air 2S**
2. **Espere conectar com o drone**
3. **Abra o app no seu Android**
4. A tela mostrará o status de conexão
5. Quando tudo estiver **Verde**, o app está pronto!

---

## 🐛 Troubleshooting

### Erro: "DJI SDK not initialized"
```bash
# Verifique a chave DJI no AndroidManifest.xml
# Certifique-se de usar a chave correta do portal DJI
```

### Erro: "Permission denied"
```bash
# Vá em Configurações → Aplicativos → Drone Flight Planner → Permissões
# Ative: Localização, Câmera, Armazenamento
```

### Erro: "Google Maps not loading"
```bash
# Adicione a chave Google Maps no AndroidManifest.xml
# Verifique SHA1 no console Google Cloud
```

### Celular não reconhece controle
```bash
# Ative Bluetooth
# Pareie manualmente o controle no Bluetooth do Android
# Tente reconectar no app
```

---

## 📲 Próximas Etapas

Após implementar este guia, os próximos componentes a desenvolver são:

1. ✅ **Tela de Status** - COMPLETA
2. 🔄 **Tela de Mapa e Editor de Polígonos** - Em progresso
3. 🔄 **Seleção de Tipo de Plano** - Em progresso
4. 🔄 **Gerenciador de Missões** - Em progresso
5. 🔄 **Tela de Parâmetros de Voo** - Em progresso
6. 🔄 **Controle de Voo Autônomo** - Em progresso

---

## 📞 Suporte

Para dúvidas sobre:
- **Flutter**: https://flutter.dev/docs
- **DJI SDK**: https://developer.dji.com/documentation
- **Google Maps**: https://developers.google.com/maps/documentation

---

**Versão do Guia**: 1.0  
**Data**: 22/07/2026  
**Status**: Em desenvolvimento
