import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dji_service.dart';
import '../services/mission_service.dart';
import '../services/telemetry_service.dart';
import '../models/flight_params.dart';
import '../models/flight_plan.dart';
import 'map_screen.dart';
import 'mission_type_screen.dart';
import 'mission_list_screen.dart';
import 'flight_params_screen.dart';
import 'flight_control_screen.dart';
import 'status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late FlightParams _currentParams;
  FlightPlan? _currentMission;
  final List<String> _titles = [
    'Status',
    'Mapa & Editor',
    'Tipo de Plano',
    'Missões',
    'Parâmetros',
    'Controle',
  ];

  @override
  void initState() {
    super.initState();
    _currentParams = FlightParams.defaultParams(-23.550520, -46.633309);
  }

  Widget _getScreenContent() {
    final djiService = context.read<DJIService>();
    final missionService = context.read<MissionService>();
    final telemetryService = context.read<TelemetryService>();

    switch (_selectedIndex) {
      case 0:
        return StatusScreen(
          djiService: djiService,
          telemetryService: telemetryService,
        );
      case 1:
        return MapScreen();
      case 2:
        return MissionTypeScreen(
          onTypeSelected: (type) {
            setState(() => _selectedIndex = 3);
          },
        );
      case 3:
        return MissionListScreen(missionService: missionService);
      case 4:
        return FlightParamsScreen(
          initialParams: _currentParams,
          onParamsChanged: (params) {
            setState(() => _currentParams = params);
          },
        );
      case 5:
        if (_currentMission == null || missionService.currentMission == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Selecione uma missão primeiro',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Vá para a aba "Missões" e selecione uma',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }
        return FlightControlScreen(
          mission: missionService.currentMission!,
          params: _currentParams,
        );
      default:
        return const SizedBox.expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionService = context.read<MissionService>();
    _currentMission = missionService.currentMission;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedIndex == 4)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  'H: ${_currentParams.flightHeight.toInt()}m',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _getScreenContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_3x3),
            label: 'Tipo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Missões',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Parâmetros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_takeoff),
            label: 'Controle',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    context.read<DJIService>().dispose();
    context.read<TelemetryService>().dispose();
    super.dispose();
  }
}
