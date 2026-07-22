# 🚁 Drone Flight Planner

Um aplicativo Flutter minimalista para planejamento e controle autônomo de voos com DJI Air 2S.

## ✨ Funcionalidades

- ✅ **Monitoramento de Conexão**: Controle Remoto, Aeronave, Gimbal, Câmera, Perfil
- ✅ **Mapa Interativo**: Visualização por satélite (Google Maps)
- ✅ **Editor de Polígonos**: Criar/editar waypoints com cálculo de área e perímetro
- ✅ **Tipos de Plano**: Linha Simples e Grelha (cruzada)
- ✅ **Gerenciador de Missões**: Criar, carregar, duplicar planos de voo
- ✅ **Configuração de Parâmetros**: Altura, velocidade, câmera, gimbal, RTH
- ✅ **Controle de Voo**: Iniciar, pausar, retomar, retornar
- ✅ **Telemetria em Tempo Real**: Bateria, satélites, sinais, altitude, velocidade
- ✅ **Interface Minimalista**: Otimizada para Android 10+

## 🛠️ Stack Técnico

- **Framework**: Flutter (Dart)
- **Drone SDK**: DJI Mobile SDK v5.x
- **Mapa**: Google Maps Flutter
- **Banco de Dados**: SQLite (localstorage)
- **Versão Mínima**: Android 10 (API 29)

## 📁 Estrutura do Projeto

```
lib/
├── models/                 # Estruturas de dados
│   ├── flight_plan.dart
│   ├── waypoint.dart
│   ├── drone_status.dart
│   └── flight_params.dart
│
├── services/              # Lógica de negócio
│   ├── dji_service.dart
│   ├── map_service.dart
│   ├── mission_service.dart
│   └── telemetry_service.dart
│
├── screens/               # Telas da aplicação
│   ├── status_screen.dart
│   ├── map_screen.dart
│   ├── mission_type_screen.dart
│   ├── mission_list_screen.dart
│   ├── flight_params_screen.dart
│   └── flight_control_screen.dart
│
├── widgets/              # Componentes reutilizáveis
│   ├── connection_indicator.dart
│   ├── map_editor.dart
│   ├── polygon_editor.dart
│   └── telemetry_panel.dart
│
└── main.dart
```

## 🚀 Começando

### Pré-requisitos

1. Flutter SDK instalado (3.0+)
2. Android Studio com Android 10+ SDK
3. Chave da API do DJI (registrada em https://developer.dji.com)
4. Google Maps API Key (opcional, para versão com mapa)

### Instalação

```bash
git clone https://github.com/Lorenzo32/DroneFlightPlanner.git
cd DroneFlightPlanner
flutter pub get
flutter run
```

### Configuração DJI

1. Registre sua chave no arquivo `android/app/src/main/AndroidManifest.xml`
2. Configure o App ID no DJI Developer Portal

## 📱 Uso

1. **Conexão**: Verificar status do drone na tela inicial
2. **Planejamento**: Desenhar polígono no mapa
3. **Configuração**: Definir altura, velocidade, câmera
4. **Execução**: Iniciar voo autônomo
5. **Monitoramento**: Acompanhar telemetria em tempo real

## 📝 Licença

AGPLv3 (compatível com ODM)

## 👥 Autor

Lorenzo32

---

**Status**: 🔧 Em desenvolvimento
