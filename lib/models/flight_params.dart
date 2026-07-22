import 'package:json_serializable/json_serializable.dart';

part 'flight_params.g.dart';

enum DJICameraType {
  air2s, // DJI Air 2S
  air3,
  air3s,
  mini3,
  mini4pro,
}

@JsonSerializable()
class FlightParams {
  final double flightHeight; // metros
  final double flightSpeed; // m/s
  final DJICameraType cameraType;
  final double cameraGimbalAngle; // graus (-90 a 0)
  final int imageOverlap; // percentual (70-90)
  final int sideOverlap; // percentual (60-80)
  final double homeLatitude;
  final double homeLongitude;
  final double? rthLatitude;
  final double? rthLongitude;
  final bool useHomeAsRTH;
  final bool enableGPS;
  final bool enableVisionPositioning;
  final int maxFlightTime; // segundos
  final bool autoReturnOnLowBattery;
  final int lowBatteryThreshold; // percentual

  FlightParams({
    required this.flightHeight,
    required this.flightSpeed,
    required this.cameraType,
    required this.cameraGimbalAngle,
    required this.imageOverlap,
    required this.sideOverlap,
    required this.homeLatitude,
    required this.homeLongitude,
    this.rthLatitude,
    this.rthLongitude,
    required this.useHomeAsRTH,
    this.enableGPS = true,
    this.enableVisionPositioning = true,
    this.maxFlightTime = 1200,
    this.autoReturnOnLowBattery = true,
    this.lowBatteryThreshold = 20,
  });

  factory FlightParams.defaultParams(double lat, double lng) => FlightParams(
    flightHeight: 50,
    flightSpeed: 5,
    cameraType: DJICameraType.air2s,
    cameraGimbalAngle: -45,
    imageOverlap: 80,
    sideOverlap: 70,
    homeLatitude: lat,
    homeLongitude: lng,
    useHomeAsRTH: true,
  );

  factory FlightParams.fromJson(Map<String, dynamic> json) =>
      _$FlightParamsFromJson(json);
  Map<String, dynamic> toJson() => _$FlightParamsToJson(this);

  FlightParams copyWith({
    double? flightHeight,
    double? flightSpeed,
    DJICameraType? cameraType,
    double? cameraGimbalAngle,
    int? imageOverlap,
    int? sideOverlap,
    double? homeLatitude,
    double? homeLongitude,
    double? rthLatitude,
    double? rthLongitude,
    bool? useHomeAsRTH,
    bool? enableGPS,
    bool? enableVisionPositioning,
    int? maxFlightTime,
    bool? autoReturnOnLowBattery,
    int? lowBatteryThreshold,
  }) {
    return FlightParams(
      flightHeight: flightHeight ?? this.flightHeight,
      flightSpeed: flightSpeed ?? this.flightSpeed,
      cameraType: cameraType ?? this.cameraType,
      cameraGimbalAngle: cameraGimbalAngle ?? this.cameraGimbalAngle,
      imageOverlap: imageOverlap ?? this.imageOverlap,
      sideOverlap: sideOverlap ?? this.sideOverlap,
      homeLatitude: homeLatitude ?? this.homeLatitude,
      homeLongitude: homeLongitude ?? this.homeLongitude,
      rthLatitude: rthLatitude ?? this.rthLatitude,
      rthLongitude: rthLongitude ?? this.rthLongitude,
      useHomeAsRTH: useHomeAsRTH ?? this.useHomeAsRTH,
      enableGPS: enableGPS ?? this.enableGPS,
      enableVisionPositioning: enableVisionPositioning ?? this.enableVisionPositioning,
      maxFlightTime: maxFlightTime ?? this.maxFlightTime,
      autoReturnOnLowBattery: autoReturnOnLowBattery ?? this.autoReturnOnLowBattery,
      lowBatteryThreshold: lowBatteryThreshold ?? this.lowBatteryThreshold,
    );
  }

  String getCameraName() {
    switch (cameraType) {
      case DJICameraType.air2s:
        return 'DJI Air 2S';
      case DJICameraType.air3:
        return 'DJI Air 3';
      case DJICameraType.air3s:
        return 'DJI Air 3S';
      case DJICameraType.mini3:
        return 'DJI Mini 3';
      case DJICameraType.mini4pro:
        return 'DJI Mini 4 Pro';
    }
  }

  double getEstimatedFlightTime() {
    // Cálculo aproximado do tempo de voo baseado na altura e velocidade
    return (maxFlightTime / 2).toDouble(); // Simplificado
  }
}
