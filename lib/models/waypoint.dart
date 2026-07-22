import 'package:json_serializable/json_serializable.dart';

part 'waypoint.g.dart';

@JsonSerializable()
class Waypoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final int order;
  final String? action; // 'takePhoto', 'startRecording', etc
  final Map<String, dynamic>? metadata;

  Waypoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.order,
    this.action,
    this.metadata,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) =>
      _$WaypointFromJson(json);
  Map<String, dynamic> toJson() => _$WaypointToJson(this);

  Waypoint copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    int? order,
    String? action,
    Map<String, dynamic>? metadata,
  }) {
    return Waypoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      order: order ?? this.order,
      action: action ?? this.action,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'Waypoint($latitude, $longitude, alt: $altitude)';
}
