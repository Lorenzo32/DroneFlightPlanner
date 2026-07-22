import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/dji_service.dart';
import 'services/mission_service.dart';
import 'services/telemetry_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<DJIService>(DJIService());
  getIt.registerSingleton<MissionService>(MissionService());
  getIt.registerSingleton<TelemetryService>(TelemetryService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  
  // Inicializar DJI SDK
  await getIt<DJIService>().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DJIService>(create: (_) => getIt<DJIService>()),
        Provider<MissionService>(create: (_) => getIt<MissionService>()),
        Provider<TelemetryService>(create: (_) => getIt<TelemetryService>()),
      ],
      child: MaterialApp(
        title: 'Drone Flight Planner',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          typography: Typography.material2021(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
