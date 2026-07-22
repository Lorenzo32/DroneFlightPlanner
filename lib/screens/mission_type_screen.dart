import 'package:flutter/material.dart';
import '../../models/flight_plan.dart';

class MissionTypeScreen extends StatefulWidget {
  final Function(MissionType) onTypeSelected;

  const MissionTypeScreen({required this.onTypeSelected, Key? key})
      : super(key: key);

  @override
  State<MissionTypeScreen> createState() => _MissionTypeScreenState();
}

class _MissionTypeScreenState extends State<MissionTypeScreen> {
  MissionType? selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Selecione o Tipo de Plano',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 20,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMissionTypeCard(
                    context,
                    title: 'Linha Simples',
                    description:
                        'Voo em linha única com waypoints sequenciais',
                    icon: Icons.trending_flat,
                    type: MissionType.linePath,
                    isSelected: selectedType == MissionType.linePath,
                    onTap: () {
                      setState(() => selectedType = MissionType.linePath);
                      widget.onTypeSelected(MissionType.linePath);
                    },
                  ),
                  _buildMissionTypeCard(
                    context,
                    title: 'Grelha (Cruzada)',
                    description:
                        'Voo em padrão de grelha para cobertura completa',
                    icon: Icons.grid_3x3,
                    type: MissionType.grid,
                    isSelected: selectedType == MissionType.grid,
                    onTap: () {
                      setState(() => selectedType = MissionType.grid);
                      widget.onTypeSelected(MissionType.grid);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedType != null
                      ? () => Navigator.pop(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Próximo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionTypeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required MissionType type,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Selecionado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
}
