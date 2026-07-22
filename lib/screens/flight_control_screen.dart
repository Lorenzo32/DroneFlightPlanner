import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/flight_plan.dart';
import '../../models/flight_params.dart';
import '../../services/dji_service.dart';
import '../../services/mission_service.dart';

class FlightControlScreen extends StatefulWidget {
  final FlightPlan mission;
  final FlightParams params;

  const FlightControlScreen({
    required this.mission,
    required this.params,
    Key? key,
  }) : super(key: key);

  @override
  State<FlightControlScreen> createState() => _FlightControlScreenState();
}

class _FlightControlScreenState extends State<FlightControlScreen> {
  bool missionStarted = false;
  bool missionPaused = false;
  int currentWaypointIndex = 0;

  @override
  Widget build(BuildContext context) {
    final djiService = context.read<DJIService>();

    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildMissionInfo(),
                const SizedBox(height: 24),
                _buildConfigurationSummary(),
                const SizedBox(height: 24),
                if (!missionStarted)
                  _buildPreFlightChecklist()
                else
                  _buildMissionProgress(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // Controles flutuantes na parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!missionStarted)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _showStartConfirmation(djiService),
                        icon: const Icon(Icons.flight_takeoff),
                        label: const Text('Iniciar Voo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    )
                  else ...
                    [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: missionPaused
                                  ? () => _resumeMission(djiService)
                                  : () => _pauseMission(djiService),
                              icon: Icon(
                                missionPaused
                                    ? Icons.play_arrow
                                    : Icons.pause,
                              ),
                              label: Text(
                                missionPaused ? 'Retomar' : 'Pausar',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _returnHome(djiService),
                              icon: const Icon(Icons.home),
                              label: const Text('Retornar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _stopMission(djiService),
                              icon: const Icon(Icons.stop),
                              label: const Text('Parar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
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
      ),
    );
  }

  Widget _buildMissionInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Missão: ${widget.mission.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.mission.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoChip(
                  icon: Icons.location_on,
                  label: 'Waypoints',
                  value: '${widget.mission.waypoints.length}',
                ),
                _buildInfoChip(
                  icon: Icons.height,
                  label: 'Altura',
                  value: '${widget.params.flightHeight.toInt()}m',
                ),
                _buildInfoChip(
                  icon: Icons.speed,
                  label: 'Velocidade',
                  value: '${widget.params.flightSpeed.toStringAsFixed(1)}m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationSummary() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text('Resumo da Configuração'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfigRow('Câmera', widget.params.getCameraName()),
                _buildConfigRow('Gimbal', '${widget.params.cameraGimbalAngle}°'),
                _buildConfigRow(
                  'Sobreposição',
                  '${widget.params.imageOverlap}% x ${widget.params.sideOverlap}%',
                ),
                _buildConfigRow('GPS', widget.params.enableGPS ? 'Ativo' : 'Inativo'),
                _buildConfigRow(
                  'Return to Home',
                  widget.params.useHomeAsRTH ? 'Ponto de decolagem' : 'Ponto customizado',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreFlightChecklist() {
    return StreamBuilder(
      stream: context.read<DJIService>().statusStream,
      builder: (context, snapshot) {
        final isReady = snapshot.hasData && (snapshot.data?.isReadyForFlight ?? false);
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isReady ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verificação Pré-Voo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildChecklistItem(
                  'Drone Conectado',
                  snapshot.hasData &&
                      (snapshot.data?.isFullyConnected ?? false),
                ),
                _buildChecklistItem(
                  'Bateria Suficiente',
                  snapshot.hasData &&
                      ((snapshot.data?.batteryPercentage ?? 0) > 20),
                ),
                _buildChecklistItem(
                  'Satélites Disponíveis',
                  snapshot.hasData &&
                      ((snapshot.data?.satelliteCount ?? 0) > 6),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isReady ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isReady ? Icons.check_circle : Icons.warning,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isReady
                              ? 'Tudo OK! Pronto para voar'
                              : 'Aguardando conexão completa...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissionProgress() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso da Missão',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (currentWaypointIndex / widget.mission.waypoints.length),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Waypoint ${currentWaypointIndex + 1} / ${widget.mission.waypoints.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missionPaused ? 'MISSÃO PAUSADA' : 'MISSÃO EM ANDAMENTO',
                    style: TextStyle(
                      color: missionPaused ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque em "Pausar" para pausar a missão ou continuar com "Retomar"',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String label, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isComplete ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isComplete ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showStartConfirmation(DJIService djiService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar Voo Autônomo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo da missão:'),
            const SizedBox(height: 8),
            _buildConfigRow('Missão', widget.mission.name),
            _buildConfigRow(
              'Waypoints',
              '${widget.mission.waypoints.length}',
            ),
            _buildConfigRow('Altura', '${widget.params.flightHeight.toInt()}m'),
            _buildConfigRow(
              'Velocidade',
              '${widget.params.flightSpeed.toStringAsFixed(1)}m/s',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _startMission(djiService);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _startMission(DJIService djiService) async {
    final success = await djiService.startMission(widget.mission.waypoints);
    if (success) {
      setState(() {
        missionStarted = true;
        missionPaused = false;
        currentWaypointIndex = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voo autônomo iniciado'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao iniciar o voo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pauseMission(DJIService djiService) async {
    final success = await djiService.pauseMission();
    if (success) {
      setState(() => missionPaused = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missão pausada')),
      );
    }
  }

  Future<void> _resumeMission(DJIService djiService) async {
    final success = await djiService.resumeMission();
    if (success) {
      setState(() => missionPaused = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missão retomada')),
      );
    }
  }

  Future<void> _returnHome(DJIService djiService) async {
    final success = await djiService.goHome();
    if (success) {
      setState(() => missionStarted = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retornando para casa'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _stopMission(DJIService djiService) async {
    final success = await djiService.stopMission();
    if (success) {
      setState(() => missionStarted = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missão parada'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
