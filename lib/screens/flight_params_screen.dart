import 'package:flutter/material.dart';
import '../../models/flight_params.dart';

class FlightParamsScreen extends StatefulWidget {
  final FlightParams initialParams;
  final Function(FlightParams) onParamsChanged;

  const FlightParamsScreen({
    required this.initialParams,
    required this.onParamsChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<FlightParamsScreen> createState() => _FlightParamsScreenState();
}

class _FlightParamsScreenState extends State<FlightParamsScreen> {
  late FlightParams params;
  late TextEditingController heightController;
  late TextEditingController speedController;
  late TextEditingController gimbalController;
  late TextEditingController homeLatController;
  late TextEditingController homeLngController;
  late TextEditingController rthLatController;
  late TextEditingController rthLngController;

  @override
  void initState() {
    super.initState();
    params = widget.initialParams;
    heightController = TextEditingController(text: params.flightHeight.toString());
    speedController = TextEditingController(text: params.flightSpeed.toString());
    gimbalController = TextEditingController(text: params.cameraGimbalAngle.toString());
    homeLatController = TextEditingController(text: params.homeLatitude.toString());
    homeLngController = TextEditingController(text: params.homeLongitude.toString());
    rthLatController = TextEditingController(text: params.rthLatitude?.toString() ?? '');
    rthLngController = TextEditingController(text: params.rthLongitude?.toString() ?? '');
  }

  void _updateParams() {
    try {
      params = params.copyWith(
        flightHeight: double.parse(heightController.text),
        flightSpeed: double.parse(speedController.text),
        cameraGimbalAngle: double.parse(gimbalController.text),
        homeLatitude: double.parse(homeLatController.text),
        homeLongitude: double.parse(homeLngController.text),
        rthLatitude: rthLatController.text.isNotEmpty ? double.parse(rthLatController.text) : null,
        rthLongitude: rthLngController.text.isNotEmpty ? double.parse(rthLngController.text) : null,
      );
      widget.onParamsChanged(params);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar parâmetros: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Configuração de Voo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // Câmera do Drone
            _buildSectionTitle(context, 'Drone e Câmera'),
            _buildDropdown(
              label: 'Tipo de Drone/Câmera',
              value: params.cameraType.toString().split('.').last,
              items: DJICameraType.values.map((e) => e.toString().split('.').last).toList(),
              onChanged: (value) {
                setState(() {
                  params = params.copyWith(
                    cameraType: DJICameraType.values.firstWhere(
                      (e) => e.toString().split('.').last == value,
                    ),
                  );
                  _updateParams();
                });
              },
            ),
            const SizedBox(height: 16),
            // Parâmetros de Altura e Velocidade
            _buildSectionTitle(context, 'Parâmetros de Voo'),
            _buildNumberInput(
              label: 'Altura de Voo (m)',
              controller: heightController,
              onChanged: (_) => _updateParams(),
              min: 10,
              max: 500,
            ),
            const SizedBox(height: 12),
            _buildNumberInput(
              label: 'Velocidade de Voo (m/s)',
              controller: speedController,
              onChanged: (_) => _updateParams(),
              min: 1,
              max: 20,
            ),
            const SizedBox(height: 12),
            _buildNumberInput(
              label: 'Ângulo do Gimbal (graus)',
              controller: gimbalController,
              onChanged: (_) => _updateParams(),
              min: -90,
              max: 0,
            ),
            const SizedBox(height: 16),
            // Sobreposição de Imagens
            _buildSectionTitle(context, 'Sobreposição'),
            _buildSlider(
              label: 'Sobreposição Frontal: ${params.imageOverlap}%',
              value: params.imageOverlap.toDouble(),
              min: 50,
              max: 90,
              onChanged: (value) {
                setState(() {
                  params = params.copyWith(imageOverlap: value.toInt());
                  _updateParams();
                });
              },
            ),
            const SizedBox(height: 12),
            _buildSlider(
              label: 'Sobreposição Lateral: ${params.sideOverlap}%',
              value: params.sideOverlap.toDouble(),
              min: 30,
              max: 80,
              onChanged: (value) {
                setState(() {
                  params = params.copyWith(sideOverlap: value.toInt());
                  _updateParams();
                });
              },
            ),
            const SizedBox(height: 16),
            // Posição de Decolagem
            _buildSectionTitle(context, 'Localização de Decolagem'),
            _buildNumberInput(
              label: 'Latitude',
              controller: homeLatController,
              onChanged: (_) => _updateParams(),
              min: -90,
              max: 90,
              decimals: 6,
            ),
            const SizedBox(height: 12),
            _buildNumberInput(
              label: 'Longitude',
              controller: homeLngController,
              onChanged: (_) => _updateParams(),
              min: -180,
              max: 180,
              decimals: 6,
            ),
            const SizedBox(height: 16),
            // Return to Home
            _buildSectionTitle(context, 'Return to Home (RTH)'),
            CheckboxListTile(
              title: const Text('Usar mesmo local de decolagem'),
              value: params.useHomeAsRTH,
              onChanged: (value) {
                setState(() {
                  params = params.copyWith(useHomeAsRTH: value ?? true);
                  _updateParams();
                });
              },
            ),
            if (!params.useHomeAsRTH) ...
              [
                const SizedBox(height: 12),
                _buildNumberInput(
                  label: 'RTH - Latitude',
                  controller: rthLatController,
                  onChanged: (_) => _updateParams(),
                  min: -90,
                  max: 90,
                  decimals: 6,
                ),
                const SizedBox(height: 12),
                _buildNumberInput(
                  label: 'RTH - Longitude',
                  controller: rthLngController,
                  onChanged: (_) => _updateParams(),
                  min: -180,
                  max: 180,
                  decimals: 6,
                ),
              ],
            const SizedBox(height: 16),
            // Configurações Avançadas
            _buildSectionTitle(context, 'Configurações Avançadas'),
            CheckboxListTile(
              title: const Text('Ativar GPS'),
              value: params.enableGPS,
              onChanged: (value) {
                setState(() {
                  params = params.copyWith(enableGPS: value ?? true);
                  _updateParams();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Posicionamento por Visão'),
              value: params.enableVisionPositioning,
              onChanged: (value) {
                setState(() {
                  params = params.copyWith(enableVisionPositioning: value ?? true);
                  _updateParams();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Retornar com Bateria Baixa'),
              value: params.autoReturnOnLowBattery,
              onChanged: (value) {
                setState(() {
                  params = params.copyWith(autoReturnOnLowBattery: value ?? true);
                  _updateParams();
                });
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required double min,
    required double max,
    int decimals = 2,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixText: '($min - $max)',
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    heightController.dispose();
    speedController.dispose();
    gimbalController.dispose();
    homeLatController.dispose();
    homeLngController.dispose();
    rthLatController.dispose();
    rthLngController.dispose();
    super.dispose();
  }
}
