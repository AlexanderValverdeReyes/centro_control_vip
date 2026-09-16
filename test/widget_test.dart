import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:centro_control_vip/data/database_helper.dart';
import 'package:centro_control_vip/data/routes/corredor_mala_lima.dart';
import 'package:centro_control_vip/providers/app_provider.dart';
import 'package:centro_control_vip/providers/despacho_provider.dart';
import 'package:centro_control_vip/providers/flota_provider.dart';
import 'package:centro_control_vip/providers/rastreo_provider.dart';
import 'package:centro_control_vip/providers/sync_provider.dart';
import 'package:centro_control_vip/providers/theme_provider.dart';
import 'package:centro_control_vip/widgets/corredor_map.dart';
import 'package:centro_control_vip/widgets/metric_card.dart';
import 'package:centro_control_vip/core/theme.dart';
import 'package:centro_control_vip/main.dart';

void main() {
  setUpAll(() async {
    await DatabaseHelper.ensureInitialized();
  });

  group('Fase 7 — Corredor Oficial Mala — Lima Tests', () {
    test('Catálogo geográfico contiene exactamente los 14 waypoints obligatorios', () {
      final waypoints = CorredorMalaLima.waypoints;
      expect(waypoints.length, equals(14));

      // Terminal Inicial: Mala (km 90)
      expect(waypoints.first.codigo, equals('TER-MALA'));
      expect(waypoints.first.km, equals(90.0));
      expect(waypoints.first.esTerminal, isTrue);

      // Terminal Final: Lima (km 0)
      expect(waypoints.last.codigo, equals('TER-LIMA'));
      expect(waypoints.last.km, equals(0.0));
      expect(waypoints.last.esTerminal, isTrue);

      // Verificar orden decreciente de kilometraje de Sur a Norte hacia Lima
      for (int i = 0; i < waypoints.length - 1; i++) {
        expect(waypoints[i].km, greaterThanOrEqualTo(waypoints[i + 1].km));
        expect(waypoints[i].orden, equals(i + 1));
      }
    });

    testWidgets('CorredorMap CustomPainter se monta y renderiza en lienzo vectorial',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CorredorMap(compact: false),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CorredorMap), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('CORREDOR 1S: PANAMERICANA SUR'), findsOneWidget);
      expect(find.text('• 14 CHECKPOINTS OFICIALES'), findsOneWidget);
    });
  });

  group('Componentes UI y Widgets Tests', () {
    testWidgets('MetricCard renderiza títulos, valores e iconos correctamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(
            body: MetricCard(
              title: 'TOTAL FLOTA ACTIVA',
              value: '12 UNIDADES',
              subtitle: 'En andén y ruta',
              icon: Icons.directions_bus,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('TOTAL FLOTA ACTIVA'), findsOneWidget);
      expect(find.text('12 UNIDADES'), findsOneWidget);
      expect(find.text('En andén y ruta'), findsOneWidget);
      expect(find.byIcon(Icons.directions_bus), findsOneWidget);
    });

    testWidgets('Layout Persistente y Smoke Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => FlotaProvider()),
            ChangeNotifierProvider(create: (_) => DespachoProvider()),
            ChangeNotifierProvider(create: (_) => RastreoProvider()),
            ChangeNotifierProvider(create: (_) => SyncProvider()),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const MainLayoutPersistent(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CONTROL VIP'), findsOneWidget);
      expect(find.text('NUEVO DESPACHO EXPRESS'), findsOneWidget);
      expect(find.text('TOTAL FLOTA ACTIVA'), findsOneWidget);
      expect(find.text('Sala de Control'), findsOneWidget);
      expect(find.text('Monitoreo 2D'), findsOneWidget);
      expect(find.text('Registro de Salidas'), findsOneWidget);
      expect(find.text('Gestión de Flota'), findsOneWidget);
    });
  });
}
