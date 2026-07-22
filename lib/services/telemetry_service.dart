import 'dart:async';
import 'package:logging/logging.dart';

final log = Logger('TelemetryService');

class TelemetryData {
  final double battery;
  final int satellites;
  final double signalStrength;
  final double altitude;
  final double speed;
  final double homeDistance;
  final DateTime timestamp;

  TelemetryData({
    required this.battery,
    required this.satellites,
    required this.signalStrength,
    required this.altitude,
    required this.speed,
    required this.homeDistance,
    required this.timestamp,
  });
}

class TelemetryService {
  final _telemetryController = StreamController<TelemetryData>.broadcast();
  final List<TelemetryData> _history = [];
  static const int maxHistorySize = 1000;

  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  List<TelemetryData> get history => _history.toList();

  void recordTelemetry(
    double battery,
    int satellites,
    double signalStrength,
    double altitude,
    double speed,
    double homeDistance,
  ) {
    final data = TelemetryData(
      battery: battery,
      satellites: satellites,
      signalStrength: signalStrength,
      altitude: altitude,
      speed: speed,
      homeDistance: homeDistance,
      timestamp: DateTime.now(),
    );

    _telemetryController.add(data);
    _history.add(data);

    // Manter histórico limitado
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }
  }

  double getAverageBattery(Duration period) {
    final now = DateTime.now();
    final filtered = _history.where((t) {
      return now.difference(t.timestamp).compareTo(period) <= 0;
    }).toList();

    if (filtered.isEmpty) return 0;
    return filtered.fold<double>(0, (sum, t) => sum + t.battery) /
        filtered.length;
  }

  double getMaxAltitude(Duration period) {
    final now = DateTime.now();
    final filtered = _history.where((t) {
      return now.difference(t.timestamp).compareTo(period) <= 0;
    }).toList();

    if (filtered.isEmpty) return 0;
    return filtered.fold<double>(0, (max, t) => max > t.altitude ? max : t.altitude);
  }

  double getMaxSpeed(Duration period) {
    final now = DateTime.now();
    final filtered = _history.where((t) {
      return now.difference(t.timestamp).compareTo(period) <= 0;
    }).toList();

    if (filtered.isEmpty) return 0;
    return filtered.fold<double>(0, (max, t) => max > t.speed ? max : t.speed);
  }

  void clearHistory() {
    log.info('Limpando histórico de telemetria');
    _history.clear();
  }

  void dispose() {
    _telemetryController.close();
  }
}
