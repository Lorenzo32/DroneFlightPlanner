import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../models/drone_status.dart';
import '../models/waypoint.dart';

final log = Logger('DJIService');

class DJIService {
  static const platform = MethodChannel('com.droneplanner/dji');
  
  final _statusController = StreamController<DroneStatus>.broadcast();
  late DroneStatus _currentStatus;
  Timer? _statusUpdateTimer;

  Stream<DroneStatus> get statusStream => _statusController.stream;
  DroneStatus get currentStatus => _currentStatus;

  DJIService() {
    _currentStatus = DroneStatus.initial();
    _setupMethodChannelListener();
  }

  Future<void> initialize() async {
    try {
      log.info('Inicializando DJI SDK...');
      final result = await platform.invokeMethod('initializeDJI');
      log.info('DJI SDK inicializado: $result');
      
      // Iniciar polling de status
      _startStatusPolling();
    } on PlatformException catch (e) {
      log.severe('Erro ao inicializar DJI SDK: ${e.message}');
      rethrow;
    }
  }

  void _setupMethodChannelListener() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDroneStatusChanged':
          _handleDroneStatusUpdate(call.arguments);
          break;
        case 'onConnectionChanged':
          _handleConnectionUpdate(call.arguments);
          break;
      }
    });
  }

  void _startStatusPolling() {
    _statusUpdateTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateStatus();
    });
  }

  Future<void> _updateStatus() async {
    try {
      final result = await platform.invokeMethod('getDroneStatus');
      if (result != null) {
        _handleDroneStatusUpdate(result);
      }
    } catch (e) {
      log.warning('Erro ao obter status do drone: $e');
    }
  }

  void _handleDroneStatusUpdate(dynamic data) {
    try {
      final statusMap = Map<String, dynamic>.from(data as Map);
      _currentStatus = _currentStatus.copyWith(
        batteryPercentage: (statusMap['battery'] as num?)?.toDouble(),
        satelliteCount: statusMap['satellites'] as int?,
        signalStrength: (statusMap['signalStrength'] as num?)?.toDouble(),
        currentAltitude: (statusMap['altitude'] as num?)?.toDouble(),
        currentSpeed: (statusMap['speed'] as num?)?.toDouble(),
        homeDistance: (statusMap['homeDistance'] as num?)?.toDouble(),
        isFlying: statusMap['isFlying'] as bool?,
      );
      _statusController.add(_currentStatus);
    } catch (e) {
      log.warning('Erro ao processar status: $e');
    }
  }

  void _handleConnectionUpdate(dynamic data) {
    try {
      final connMap = Map<String, dynamic>.from(data as Map);
      _currentStatus = _currentStatus.copyWith(
        remoteControllerStatus: _parseConnectionStatus(connMap['rc']),
        aircraftStatus: _parseConnectionStatus(connMap['aircraft']),
        gimbalStatus: _parseConnectionStatus(connMap['gimbal']),
        cameraStatus: _parseConnectionStatus(connMap['camera']),
        droneProfileStatus: _parseConnectionStatus(connMap['profile']),
      );
      _statusController.add(_currentStatus);
    } catch (e) {
      log.warning('Erro ao processar conexão: $e');
    }
  }

  ConnectionStatus _parseConnectionStatus(dynamic value) {
    if (value == null) return ConnectionStatus.disconnected;
    switch (value.toString().toLowerCase()) {
      case 'connected':
        return ConnectionStatus.connected;
 n      case 'connecting':
        return ConnectionStatus.connecting;
      default:
        return ConnectionStatus.disconnected;
    }
  }

  Future<bool> startMission(List<Waypoint> waypoints) async {
    try {
      log.info('Iniciando missão com ${waypoints.length} waypoints');
      final waypointsList = waypoints
          .map((wp) => {
                'latitude': wp.latitude,
                'longitude': wp.longitude,
                'altitude': wp.altitude ?? 50,
                'order': wp.order,
              })
          .toList();

      final result = await platform.invokeMethod('startMission', {
        'waypoints': waypointsList,
      });
      return result == true;
    } on PlatformException catch (e) {
      log.severe('Erro ao iniciar missão: ${e.message}');
      return false;
    }
  }

  Future<bool> pauseMission() async {
    try {
      log.info('Pausando missão');
      final result = await platform.invokeMethod('pauseMission');
      return result == true;
    } on PlatformException catch (e) {
      log.severe('Erro ao pausar missão: ${e.message}');
      return false;
    }
  }

  Future<bool> resumeMission() async {
    try {
      log.info('Retomando missão');
      final result = await platform.invokeMethod('resumeMission');
      return result == true;
    } on PlatformException catch (e) {
      log.severe('Erro ao retomar missão: ${e.message}');
      return false;
    }
  }

  Future<bool> stopMission() async {
    try {
      log.info('Parando missão');
      final result = await platform.invokeMethod('stopMission');
      return result == true;
    } on PlatformException catch (e) {
      log.severe('Erro ao parar missão: ${e.message}');
      return false;
    }
  }

  Future<bool> goHome() async {
    try {
      log.info('Retornando para casa');
      final result = await platform.invokeMethod('goHome');
      return result == true;
    } on PlatformException catch (e) {
      log.severe('Erro ao retornar para casa: ${e.message}');
      return false;
    }
  }

  Future<bool> setHomeLocation(double latitude, double longitude) async {
    try {
      log.info('Definindo local de decolagem: $latitude, $longitude');
      final result = await platform.invokeMethod('setHomeLocation', {
        'latitude': latitude,
        'longitude': longitude,
      });
      return result == true;
    } on PlatformException catch (e) {
      log.severe('Erro ao definir local de decolagem: ${e.message}');
      return false;
    }
  }

  Future<bool> setGimbalAngle(double angle) async {
    try {
      final result = await platform.invokeMethod('setGimbalAngle', {
        'angle': angle,
      });
      return result == true;
    } on PlatformException catch (e) {
      log.severe('Erro ao ajustar gimbal: ${e.message}');
      return false;
    }
  }

  void dispose() {
    _statusUpdateTimer?.cancel();
    _statusController.close();
  }
}
