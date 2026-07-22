import 'package:json_serializable/json_serializable.dart';
import 'waypoint.dart';

part 'flight_plan.g.dart';

enum MissionType { linePath, grid }

@JsonSerializable()
class FlightPlan {
  final String id;
  final String name;
  final String description;
  final List<Waypoint> waypoints;
  final MissionType missionType;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final Map<String, dynamic> parameters;
  final double? homeLatitude;
  final double? homeLongitude;
  final bool useHomeAsRTH;

  FlightPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.waypoints,
    required this.missionType,
    required this.createdAt,
    this.modifiedAt,
    required this.parameters,
    this.homeLatitude,
    this.homeLongitude,
    this.useHomeAsRTH = true,
  });

  factory FlightPlan.fromJson(Map<String, dynamic> json) =>
      _$FlightPlanFromJson(json);
  Map<String, dynamic> toJson() => _$FlightPlanToJson(this);

  FlightPlan copyWith({
    String? id,
    String? name,
    String? description,
    List<Waypoint>? waypoints,
    MissionType? missionType,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? parameters,
    double? homeLatitude,
    double? homeLongitude,
    bool? useHomeAsRTH,
  }) {
    return FlightPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      waypoints: waypoints ?? this.waypoints,
      missionType: missionType ?? this.missionType,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      parameters: parameters ?? this.parameters,
      homeLatitude: homeLatitude ?? this.homeLatitude,
      homeLongitude: homeLongitude ?? this.homeLongitude,
      useHomeAsRTH: useHomeAsRTH ?? this.useHomeAsRTH,
    );
  }

  double calculateArea() {
    if (waypoints.length < 3) return 0;
    
    double area = 0;
    for (int i = 0; i < waypoints.length; i++) {
      final p1 = waypoints[i];
      final p2 = waypoints[(i + 1) % waypoints.length];
      area += (p2.longitude - p1.longitude) * (p2.latitude + p1.latitude);
    }
    return (area.abs() / 2) * 111320 * 111320; // em m²
  }

  double calculatePerimeter() {
    if (waypoints.length < 2) return 0;
    
    double perimeter = 0;
    for (int i = 0; i < waypoints.length; i++) {
      final p1 = waypoints[i];
      final p2 = waypoints[(i + 1) % waypoints.length];
      final dLat = p2.latitude - p1.latitude;
      final dLng = p2.longitude - p1.longitude;
      perimeter += (dLat * dLat + dLng * dLng).sqrt() * 111320;
    }
    return perimeter;
  }

  @override
  String toString() => 'FlightPlan($name, ${waypoints.length} waypoints)';
}
