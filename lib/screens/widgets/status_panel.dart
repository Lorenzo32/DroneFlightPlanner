import 'package:flutter/material.dart';
import '../../models/drone_status.dart';

class StatusPanel extends StatelessWidget {
  final DroneStatus status;

  const StatusPanel({required this.status, Key? key}) : super(key: key);

  Color _getStatusColor(ConnectionStatus connStatus) {
    switch (connStatus) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  String _getStatusText(ConnectionStatus connStatus) {
    switch (connStatus) {
      case ConnectionStatus.connected:
        return 'Conectado';
      case ConnectionStatus.connecting:
        return 'Conectando';
      case ConnectionStatus.disconnected:
        return 'Desconectado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusItem('RC', status.remoteControllerStatus),
            _buildStatusItem('Drone', status.aircraftStatus),
            _buildStatusItem('Gimbal', status.gimbalStatus),
            _buildStatusItem('Câmera', status.cameraStatus),
            _buildStatusItem('Perfil', status.droneProfileStatus),
            if (status.batteryPercentage != null) ...
              SizedBox(
                width: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Bateria', style: TextStyle(fontSize: 10)),
                    Text(
                      '${status.batteryPercentage?.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            if (status.satelliteCount != null) ...
              SizedBox(
                width: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Satélites', style: TextStyle(fontSize: 10)),
                    Text(
                      '${status.satelliteCount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, ConnectionStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(top: 4),
          ),
          Text(
            _getStatusText(status),
            style: const TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }
}
