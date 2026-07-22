import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../../models/waypoint.dart';
import '../../models/flight_plan.dart';
import '../widgets/polygon_editor.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final List<Waypoint> waypoints = [];
  bool isEditingPolygon = false;
  Set<Polygon> polygons = {};
  Set<Marker> markers = {};
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    currentLocation = const LatLng(-23.550520, -46.633309); // São Paulo padrão
  }

  void _addWaypoint(LatLng position) {
    if (!isEditingPolygon) return;

    setState(() {
      final waypoint = Waypoint(
        latitude: position.latitude,
        longitude: position.longitude,
        order: waypoints.length,
      );
      waypoints.add(waypoint);
      _updateMarkers();
    });
  }

  void _removeWaypoint(int index) {
    setState(() {
      waypoints.removeAt(index);
      // Reindexar
      for (int i = 0; i < waypoints.length; i++) {
        waypoints[i] = waypoints[i].copyWith(order: i);
      }
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    final newMarkers = <Marker>{};
    
    for (int i = 0; i < waypoints.length; i++) {
      final wp = waypoints[i];
      newMarkers.add(
        Marker(
          markerId: MarkerId('waypoint_$i'),
          position: LatLng(wp.latitude, wp.longitude),
          infoWindow: InfoWindow(
            title: 'Waypoint ${i + 1}',
            onTap: () => _removeWaypoint(i),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    // Linha de rota
    if (waypoints.length > 1) {
      final polylinePoints = <LatLng>[];
      for (final wp in waypoints) {
        polylinePoints.add(LatLng(wp.latitude, wp.longitude));
      }
      // Fechar polígono
      polylinePoints.add(LatLng(waypoints.first.latitude, waypoints.first.longitude));
    }

    setState(() {
      markers = newMarkers;
    });
  }

  void _finishPolygonEditing() {
    if (waypoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos 3 pontos')),
      );
      return;
    }

    setState(() {
      isEditingPolygon = false;
    });

    final area = _calculateArea();
    final perimeter = _calculatePerimeter();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Polígono Finalizado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pontos: ${waypoints.length}'),
            Text('Área: ${(area / 1000000).toStringAsFixed(2)} km²'),
            Text('Perímetro: ${(perimeter / 1000).toStringAsFixed(2)} km'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  double _calculateArea() {
    if (waypoints.length < 3) return 0;
    
    double area = 0;
    for (int i = 0; i < waypoints.length; i++) {
      final p1 = waypoints[i];
      final p2 = waypoints[(i + 1) % waypoints.length];
      area += (p2.longitude - p1.longitude) * (p2.latitude + p1.latitude);
    }
    return (area.abs() / 2) * 111320 * 111320;
  }

  double _calculatePerimeter() {
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mapa
        GoogleMap(
          onMapCreated: (controller) {
            mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: currentLocation!,
            zoom: 15,
          ),
          markers: markers,
          mapType: MapType.satellite,
          onTap: _addWaypoint,
          zoomControlsEnabled: true,
        ),
        // Painel flutuante de controle
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditingPolygon)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isEditingPolygon = true;
                          waypoints.clear();
                          markers.clear();
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Polígono'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else ...
                  [
                    Text(
                      'Pontos adicionados: ${waypoints.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (waypoints.length >= 2) ...
                      [
                        const SizedBox(height: 8),
                        Text(
                          'Área: ${(_calculateArea() / 1000000).toStringAsFixed(2)} km²',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Perímetro: ${(_calculatePerimeter() / 1000).toStringAsFixed(2)} km',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isEditingPolygon = false;
                                waypoints.clear();
                                markers.clear();
                              });
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Cancelar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: waypoints.length >= 3
                                ? _finishPolygonEditing
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text('Concluir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
