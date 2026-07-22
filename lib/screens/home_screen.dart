import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dji_service.dart';
import '../models/drone_status.dart';
import 'widgets/status_panel.dart';
import 'widgets/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DroneStatus>(
        stream: context.read<DJIService>().statusStream,
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Conteúdo principal (será implementado depois)
              Center(
                child: Text(
                  'Tela ${_selectedIndex + 1}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              // Painel de status flutuante
              if (snapshot.hasData)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: StatusPanel(status: snapshot.data!),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBarWidget(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    context.read<DJIService>().dispose();
    super.dispose();
  }
}
