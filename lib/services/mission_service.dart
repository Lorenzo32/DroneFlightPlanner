import 'package:logging/logging.dart';
import '../models/flight_plan.dart';
import '../models/waypoint.dart';

final log = Logger('MissionService');

class MissionService {
  final List<FlightPlan> _missions = [];
  FlightPlan? _currentMission;

  List<FlightPlan> get missions => _missions;
  FlightPlan? get currentMission => _currentMission;

  // Gerar waypoints para linha simples
  List<Waypoint> generateLinePath(
    List<Waypoint> polygonPoints,
    double flightHeight,
    int imageOverlap,
  ) {
    log.info('Gerando caminho de linha simples...');
    
    final waypoints = <Waypoint>[];
    int order = 0;

    // Converter pontos do polígono para waypoints com altura
    for (final point in polygonPoints) {
      waypoints.add(
        Waypoint(
          latitude: point.latitude,
          longitude: point.longitude,
          altitude: flightHeight,
          order: order++,
          action: 'takePhoto',
        ),
      );
    }

    log.info('Caminho de linha gerado: ${waypoints.length} waypoints');
    return waypoints;
  }

  // Gerar waypoints para grelha (cruzada)
  List<Waypoint> generateGridPath(
    List<Waypoint> polygonPoints,
    double flightHeight,
    int imageOverlap,
    double spacing,
  ) {
    log.info('Gerando caminho de grelha...');
    
    if (polygonPoints.length < 3) {
      log.warning('Polígono inválido para grelha');
      return [];
    }

    final waypoints = <Waypoint>[];
    int order = 0;

    // Calcular bounding box
    double minLat = polygonPoints.first.latitude;
    double maxLat = polygonPoints.first.latitude;
    double minLng = polygonPoints.first.longitude;
    double maxLng = polygonPoints.first.longitude;

    for (final point in polygonPoints) {
      minLat = minLat > point.latitude ? point.latitude : minLat;
      maxLat = maxLat < point.latitude ? point.latitude : maxLat;
      minLng = minLng > point.longitude ? point.longitude : minLng;
      maxLng = maxLng < point.longitude ? point.longitude : maxLng;
    }

    // Gerar grid de waypoints
    double lat = minLat;
    bool goingEast = true;

    while (lat <= maxLat) {
      if (goingEast) {
        // Linha de oeste para leste
        for (double lng = minLng; lng <= maxLng; lng += spacing) {
          if (_isInsidePolygon(lat, lng, polygonPoints)) {
            waypoints.add(
              Waypoint(
                latitude: lat,
                longitude: lng,
                altitude: flightHeight,
                order: order++,
                action: 'takePhoto',
              ),
            );
          }
        }
      } else {
        // Linha de leste para oeste
        for (double lng = maxLng; lng >= minLng; lng -= spacing) {
          if (_isInsidePolygon(lat, lng, polygonPoints)) {
            waypoints.add(
              Waypoint(
                latitude: lat,
                longitude: lng,
                altitude: flightHeight,
                order: order++,
                action: 'takePhoto',
              ),
            );
          }
        }
      }
      goingEast = !goingEast;
      lat += spacing;
    }

    log.info('Grid gerado: ${waypoints.length} waypoints');
    return waypoints;
  }

  // Verificar se ponto está dentro do polígono (algoritmo ray casting)
  bool _isInsidePolygon(double lat, double lng, List<Waypoint> polygon) {
    int intersectionCount = 0;

    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      if (((p1.latitude <= lat && lat < p2.latitude) ||
              (p2.latitude <= lat && lat < p1.latitude)) &&
          (lng <
              (p2.longitude - p1.longitude) *
                      (lat - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersectionCount++;
      }
    }

    return intersectionCount % 2 == 1;
  }

  FlightPlan createMission(
    String name,
    String description,
    List<Waypoint> waypoints,
    MissionType type,
  ) {
    log.info('Criando missão: $name');
    
    final mission = FlightPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      waypoints: waypoints,
      missionType: type,
      createdAt: DateTime.now(),
      parameters: {},
    );

    _missions.add(mission);
    _currentMission = mission;
    return mission;
  }

  void updateCurrentMission(FlightPlan mission) {
    log.info('Atualizando missão: ${mission.name}');
    _currentMission = mission;
    
    final index = _missions.indexWhere((m) => m.id == mission.id);
    if (index >= 0) {
      _missions[index] = mission;
    }
  }

  void selectMission(String missionId) {
    log.info('Selecionando missão: $missionId');
    _currentMission = _missions.firstWhere(
      (m) => m.id == missionId,
      orElse: () => throw Exception('Missão não encontrada'),
    );
  }

  void deleteMission(String missionId) {
    log.info('Deletando missão: $missionId');
    _missions.removeWhere((m) => m.id == missionId);
    if (_currentMission?.id == missionId) {
      _currentMission = null;
    }
  }

  FlightPlan? duplicateMission(String missionId) {
    log.info('Duplicando missão: $missionId');
    final mission = _missions.firstWhere(
      (m) => m.id == missionId,
      orElse: () => throw Exception('Missão não encontrada'),
    );

    final duplicate = mission.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${mission.name} (cópia)',
      createdAt: DateTime.now(),
    );

    _missions.add(duplicate);
    return duplicate;
  }
}
