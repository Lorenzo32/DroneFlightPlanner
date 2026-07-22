import 'package:flutter/material.dart';

class NavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const NavigationBarWidget({
    required this.selectedIndex,
    required this.onItemSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemSelected,
      type: BottomNavigationBarType.fixed,
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
    );
  }
}
