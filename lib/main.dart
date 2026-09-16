import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/sync_engine.dart';
import 'core/theme.dart';
import 'data/database_helper.dart';
import 'providers/app_provider.dart';
import 'providers/despacho_provider.dart';
import 'providers/flota_provider.dart';
import 'providers/rastreo_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/theme_provider.dart';
import 'views/flota_view.dart';
import 'views/monitoreo_rutas_view.dart';
import 'views/registro_salidas_view.dart';
import 'views/sala_control_view.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_header.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización centralizada única de SQLite nativo
  await DatabaseHelper.ensureInitialized();

  // Iniciar motor de sincronización en segundo plano
  SyncEngine.instance.start();

  runApp(const VIPControlCenterApp());
}

class VIPControlCenterApp extends StatefulWidget {
  const VIPControlCenterApp({super.key});

  @override
  State<VIPControlCenterApp> createState() => _VIPControlCenterAppState();
}

class _VIPControlCenterAppState extends State<VIPControlCenterApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onDetach: () {
        DatabaseHelper.instance.close();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => FlotaProvider()),
        ChangeNotifierProvider(create: (_) => DespachoProvider()),
        ChangeNotifierProvider(create: (_) => RastreoProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            title: 'Centro de Control VIP — Mala / Lima',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(), // Modo Claro por defecto
            darkTheme: buildDarkTheme(),
            themeMode: themeProv.themeMode,
            home: const MainLayoutPersistent(),
          );
        },
      ),
    );
  }
}

/// Layout Persistente para Windows Desktop a 1920x1080
/// - AppSidebar: Ancho 250px exacto con navegación entre 4 vistas y estado de sync.
/// - TopHeader: Altura 84px exacto con datos del terminal activo, reloj en vivo, toggle claro/oscuro y botón dorado NUEVO DESPACHO EXPRESS.
class MainLayoutPersistent extends StatelessWidget {
  const MainLayoutPersistent({super.key});

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final palette = context.palette;

    Widget currentView;
    switch (appProv.currentIndex) {
      case 0:
        currentView = const SalaControlView();
        break;
      case 1:
        currentView = const MonitoreoRutasView();
        break;
      case 2:
        currentView = const RegistroSalidasView();
        break;
      case 3:
        currentView = const FlotaView();
        break;
      default:
        currentView = const SalaControlView();
    }

    return Scaffold(
      backgroundColor: palette.background,
      body: Row(
        children: [
          // Sidebar Fijo 250px
          const AppSidebar(),

          // Área Principal de Trabajo
          Expanded(
            child: Column(
              children: [
                // Top Header Fijo 84px
                const TopHeader(),

                // Vista Activa
                Expanded(child: currentView),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
