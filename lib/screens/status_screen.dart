import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/drone_status.dart';
import '../services/dji_service.dart';
import '../services/telemetry_service.dart';

class StatusScreen extends StatelessWidget {
  final DJIService djiService;
  final TelemetryService telemetryService;

  const StatusScreen({
    required this.djiService,
    required this.telemetryService,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DroneStatus>(
      stream: djiService.statusStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Conectando com o drone...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final status = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildConnectionStatus(context, status),
              const SizedBox(height: 20),
              _buildBatterySection(context, status),
              const SizedBox(height: 20),
              _buildTelemetrySection(context, status),
              const SizedBox(height: 20),
              _buildSignalSection(context, status),
              const SizedBox(height: 20),
              _buildDetailedConnectionStatus(context, status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectionStatus(BuildContext context, DroneStatus status) {
    final isConnected = status.isFullyConnected;
    final isReady = status.isReadyForFlight;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isReady ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isReady ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isReady ? 'PRONTO PARA VOAR' : 'PREPARANDO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isReady ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isConnected
                  ? 'Sistema completamente conectado'
                  : 'Aguardando conexão completa...',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatterySection(BuildContext context, DroneStatus status) {
    final battery = status.batteryPercentage ?? 0;
    final batteryColor = battery > 50
        ? Colors.green
        : battery > 20
            ? Colors.orange
            : Colors.red;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bateria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${battery.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: batteryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: battery / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              battery > 50
                  ? 'Bateria em bom estado'
                  : battery > 20
                      ? 'Bateria moderada'
                      : 'Bateria crítica',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetrySection(BuildContext context, DroneStatus status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Telemetria',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTelemetryItem(
                  context,
                  icon: Icons.height,
                  label: 'Altitude',
                  value: '${(status.currentAltitude ?? 0).toStringAsFixed(1)}m',
                ),
                _buildTelemetryItem(
                  context,
                  icon: Icons.speed,
                  label: 'Velocidade',
                  value: '${(status.currentSpeed ?? 0).toStringAsFixed(1)}m/s',
                ),
                _buildTelemetryItem(
                  context,
                  icon: Icons.home,
                  label: 'Distância',
                  value: '${(status.homeDistance ?? 0).toStringAsFixed(1)}m',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.blue.shade700),
        const SizedBox(height: 8),
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

  Widget _buildSignalSection(BuildContext context, DroneStatus status) {
    final signal = status.signalStrength ?? 0;
    final satellites = status.satelliteCount ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sinal & GPS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Força do Sinal'),
                Text(
                  '${signal.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: signal / 100,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Satélites'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: satellites > 6 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$satellites',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedConnectionStatus(
      BuildContext context, DroneStatus status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status de Conexão',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildConnectionItem(
              context,
              label: 'Controle Remoto',
              status: status.remoteControllerStatus,
            ),
            const Divider(),
            _buildConnectionItem(
              context,
              label: 'Aeronave',
              status: status.aircraftStatus,
            ),
            const Divider(),
            _buildConnectionItem(
              context,
              label: 'Gimbal',
              status: status.gimbalStatus,
            ),
            const Divider(),
            _buildConnectionItem(
              context,
              label: 'Câmera',
              status: status.cameraStatus,
            ),
            const Divider(),
            _buildConnectionItem(
              context,
              label: 'Perfil do Drone',
              status: status.droneProfileStatus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionItem(
    BuildContext context, {
    required String label,
    required ConnectionStatus status,
  }) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case ConnectionStatus.connected:
        statusColor = Colors.green;
        statusText = 'Conectado';
        statusIcon = Icons.check_circle;
        break;
      case ConnectionStatus.connecting:
        statusColor = Colors.orange;
        statusText = 'Conectando';
        statusIcon = Icons.autorenew;
        break;
      case ConnectionStatus.disconnected:
        statusColor = Colors.red;
        statusText = 'Desconectado';
        statusIcon = Icons.error;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Row(
            children: [
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                statusIcon,
                color: statusColor,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
