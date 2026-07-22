import 'package:json_serializable/json_serializable.dart';

part 'drone_status.g.dart';

enum ConnectionStatus { disconnected, connecting, connected }

@JsonSerializable()
class DroneStatus {
  final ConnectionStatus remoteControllerStatus;
  final ConnectionStatus aircraftStatus;
  final ConnectionStatus gimbalStatus;
  final ConnectionStatus cameraStatus;
  final ConnectionStatus droneProfileStatus;
  
  // Telemetria
  final double? batteryPercentage;
  final int? satelliteCount;
  final double? signalStrength; // 0-100
  final double? currentAltitude;
  final double? currentSpeed;
  final double? homeDistance;
  final bool? isFlying;
  final DateTime lastUpdate;

  DroneStatus({
    required this.remoteControllerStatus,
    required this.aircraftStatus,
    required this.gimbalStatus,
    required this.cameraStatus,
    required this.droneProfileStatus,
    this.batteryPercentage,
    this.satelliteCount,
    this.signalStrength,
    this.currentAltitude,
    this.currentSpeed,
    this.homeDistance,
    this.isFlying,
    required this.lastUpdate,
  });

  factory DroneStatus.initial() => DroneStatus(
    remoteControllerStatus: ConnectionStatus.disconnected,
    aircraftStatus: ConnectionStatus.disconnected,
    gimbalStatus: ConnectionStatus.disconnected,
    cameraStatus: ConnectionStatus.disconnected,
    droneProfileStatus: ConnectionStatus.disconnected,
    lastUpdate: DateTime.now(),
  );

  factory DroneStatus.fromJson(Map<String, dynamic> json) =>
      _$DroneStatusFromJson(json);
  Map<String, dynamic> toJson() => _$DroneStatusToJson(this);

  bool get isFullyConnected =>
      remoteControllerStatus == ConnectionStatus.connected &&
      aircraftStatus == ConnectionStatus.connected &&
      gimbalStatus == ConnectionStatus.connected &&
      cameraStatus == ConnectionStatus.connected &&
      droneProfileStatus == ConnectionStatus.connected;

  bool get isReadyForFlight =>
      isFullyConnected && (batteryPercentage ?? 0) > 20;

  DroneStatus copyWith({
    ConnectionStatus? remoteControllerStatus,
    ConnectionStatus? aircraftStatus,
    ConnectionStatus? gimbalStatus,
    ConnectionStatus? cameraStatus,
    ConnectionStatus? droneProfileStatus,
    double? batteryPercentage,
    int? satelliteCount,
    double? signalStrength,
    double? currentAltitude,
    double? currentSpeed,
    double? homeDistance,
    bool? isFlying,
  }) {
    return DroneStatus(
      remoteControllerStatus: remoteControllerStatus ?? this.remoteControllerStatus,
      aircraftStatus: aircraftStatus ?? this.aircraftStatus,
      gimbalStatus: gimbalStatus ?? this.gimbalStatus,
      cameraStatus: cameraStatus ?? this.cameraStatus,
      droneProfileStatus: droneProfileStatus ?? this.droneProfileStatus,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      satelliteCount: satelliteCount ?? this.satelliteCount,
      signalStrength: signalStrength ?? this.signalStrength,
      currentAltitude: currentAltitude ?? this.currentAltitude,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      homeDistance: homeDistance ?? this.homeDistance,
      isFlying: isFlying ?? this.isFlying,
      lastUpdate: DateTime.now(),
    );
  }
}
