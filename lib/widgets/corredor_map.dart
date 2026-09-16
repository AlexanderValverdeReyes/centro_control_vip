import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/routes/corredor_mala_lima.dart';
import '../models/despacho.dart';

/// Mapa Vectorial del Corredor Mala — Lima (Panamericana Sur Ruta 1S)
/// Renderizado 100% nativo con CustomPainter sin librerías externas ni imágenes rasterizadas.
class CorredorMap extends StatefulWidget {
  final bool compact;
  final List<Despacho> despachosActivos;
  final String? ultimoCheckpointCodigo;
  final Function(WaypointCorredor)? onCheckpointSelected;
  final WaypointCorredor? selectedWaypoint;

  const CorredorMap({
    super.key,
    this.compact = false,
    this.despachosActivos = const [],
    this.ultimoCheckpointCodigo,
    this.onCheckpointSelected,
    this.selectedWaypoint,
  });

  @override
  State<CorredorMap> createState() => _CorredorMapState();
}

class _CorredorMapState extends State<CorredorMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  WaypointCorredor? _inspectedPoint;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _inspectedPoint = widget.selectedWaypoint;
  }

  @override
  void didUpdateWidget(covariant CorredorMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWaypoint != oldWidget.selectedWaypoint) {
      setState(() {
        _inspectedPoint = widget.selectedWaypoint;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details, Size size) {
    final points = _getProjectedPoints(size);
    WaypointCorredor? tapped;
    double minDistance = 24.0; // radio de detección táctil

    for (int i = 0; i < CorredorMalaLima.waypoints.length; i++) {
      final wp = CorredorMalaLima.waypoints[i];
      final offset = points[i];
      final distance = (offset - details.localPosition).distance;
      if (distance < minDistance) {
        minDistance = distance;
        tapped = wp;
      }
    }

    setState(() {
      _inspectedPoint = tapped;
    });

    if (tapped != null && widget.onCheckpointSelected != null) {
      widget.onCheckpointSelected!(tapped);
    }
  }

  List<Offset> _getProjectedPoints(Size size) {
    const minLat = -12.70;
    const maxLat = -12.02;
    const minLng = -77.06;
    const maxLng = -76.58;

    final padX = widget.compact ? 36.0 : 64.0;
    final padY = widget.compact ? 28.0 : 48.0;

    final drawWidth = size.width - 2 * padX;
    final drawHeight = size.height - 2 * padY;

    return CorredorMalaLima.waypoints.map((wp) {
      // Invertir latitud para coordenada Y de pantalla (Norte = arriba, Sur = abajo)
      final normY = (maxLat - wp.lat) / (maxLat - minLat);
      // Longitud X (Oeste = izquierda, Este = derecha)
      final normX = (wp.lng - minLng) / (maxLng - minLng);

      final x = padX + normX * drawWidth;
      final y = padY + normY * drawHeight;
      return Offset(x, y);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // Lienzo Vectorial con CustomPainter
            GestureDetector(
              onTapUp: (details) => _handleTapUp(details, size),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    size: size,
                    painter: _CorredorPainter(
                      palette: palette,
                      compact: widget.compact,
                      despachosActivos: widget.despachosActivos,
                      ultimoCheckpointCodigo: widget.ultimoCheckpointCodigo,
                      inspectedWaypoint: _inspectedPoint,
                      pulseAnimationValue: _pulseController.value,
                    ),
                  );
                },
              ),
            ),

            // Encabezado técnico del radar (en la esquina superior izquierda)
            Positioned(
              top: widget.compact ? 8 : 16,
              left: widget.compact ? 8 : 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.surface.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: palette.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: palette.exito,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: palette.exito.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CORREDOR 1S: PANAMERICANA SUR',
                      style: context.mono(
                        fontSize: widget.compact ? 10 : 11,
                        fontWeight: FontWeight.bold,
                        color: palette.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• 14 CHECKPOINTS OFICIALES',
                      style: context.mono(
                        fontSize: widget.compact ? 9 : 10,
                        color: palette.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tarjeta de inspección de Checkpoint (si hay uno seleccionado y no es compact)
            if (_inspectedPoint != null && !widget.compact)
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildInspectionCard(context, _inspectedPoint!),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInspectionCard(BuildContext context, WaypointCorredor wp) {
    final palette = context.palette;
    final isTerminal = wp.esTerminal;

    // Buscar si hay vehículos cerca o que hayan pasado por aquí
    final despachosCercanos = widget.despachosActivos.where((d) {
      return (d.ultimoCheckpoint != null && d.ultimoCheckpoint == wp.codigo);
    }).toList();

    return Container(
      width: 290,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTerminal ? palette.gold : palette.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isTerminal
                      ? palette.gold.withValues(alpha: 0.15)
                      : palette.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isTerminal ? palette.gold : palette.primary,
                  ),
                ),
                child: Text(
                  wp.codigo,
                  style: context.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isTerminal ? palette.gold : palette.primary,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _inspectedPoint = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            wp.nombre,
            style: context.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: palette.textoPrincipal,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: palette.outline, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Distancia a Lima:',
                  style: context.inter(
                      fontSize: 11, color: palette.textoSecundario)),
              Text(
                '${wp.km.toStringAsFixed(1)} KM',
                style: context.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.textoPrincipal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Coordenadas:',
                  style: context.inter(
                      fontSize: 11, color: palette.textoSecundario)),
              Text(
                '${wp.lat.toStringAsFixed(3)}, ${wp.lng.toStringAsFixed(3)}',
                style: context.mono(
                  fontSize: 10,
                  color: palette.textoSecundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Orden en Corredor:',
                  style: context.inter(
                      fontSize: 11, color: palette.textoSecundario)),
              Text(
                'Nodo ${wp.orden} de 14',
                style: context.mono(
                  fontSize: 11,
                  color: palette.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (despachosCercanos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: palette.exito.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.exito.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_bus, size: 14, color: palette.exito),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Último paso: ${despachosCercanos.first.unidadCodigo ?? "UNIDAD VIP"}',
                      style: context.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: palette.exito,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CorredorPainter extends CustomPainter {
  final AppPalette palette;
  final bool compact;
  final List<Despacho> despachosActivos;
  final String? ultimoCheckpointCodigo;
  final WaypointCorredor? inspectedWaypoint;
  final double pulseAnimationValue;

  _CorredorPainter({
    required this.palette,
    required this.compact,
    required this.despachosActivos,
    required this.ultimoCheckpointCodigo,
    required this.inspectedWaypoint,
    required this.pulseAnimationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 50 || size.height <= 50) return;

    _drawRadarGrid(canvas, size);
    _drawCoastlineAndGeography(canvas, size);

    // Calcular puntos proyectados
    final points = _computeProjectedPoints(size);

    // Generar curva suave de la Panamericana Sur
    final corridorPath = _createCurvedRoute(points);

    // Dibujar la carretera (efecto doble trazo y brillo)
    _drawHighway(canvas, corridorPath);

    // Dibujar los 14 Checkpoints oficiales
    _drawCheckpoints(canvas, points);

    // Dibujar los buses en tránsito en la ruta
    _drawActiveBuses(canvas, corridorPath, size);
  }

  void _drawRadarGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Coordenadas sutiles en los márgenes
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final coordStyle = TextStyle(
      fontSize: 8,
      fontFamily: 'monospace',
      color: palette.textoSecundario.withValues(alpha: 0.35),
    );

    for (double y = 60; y < size.height - 20; y += 120) {
      textPainter.text = TextSpan(text: 'S 12°${(y / 20).toInt()}\'', style: coordStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, y));
    }
  }

  void _drawCoastlineAndGeography(Canvas canvas, Size size) {
    // Franja sutil que representa el Océano Pacífico al Oeste (izquierda de la Panamericana)
    final oceanPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width * 0.45, size.height),
        [
          palette.primary.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      );

    final oceanPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, 0)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.45,
        size.width * 0.55,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(oceanPath, oceanPaint);

    // Línea de Costa sutil discontinua
    final coastPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(oceanPath, coastPaint);
  }

  List<Offset> _computeProjectedPoints(Size size) {
    const minLat = -12.70;
    const maxLat = -12.02;
    const minLng = -77.06;
    const maxLng = -76.58;

    final padX = compact ? 36.0 : 64.0;
    final padY = compact ? 28.0 : 48.0;

    final drawWidth = size.width - 2 * padX;
    final drawHeight = size.height - 2 * padY;

    return CorredorMalaLima.waypoints.map((wp) {
      final normY = (maxLat - wp.lat) / (maxLat - minLat);
      final normX = (wp.lng - minLng) / (maxLng - minLng);

      final x = padX + normX * drawWidth;
      final y = padY + normY * drawHeight;
      return Offset(x, y);
    }).toList();
  }

  Path _createCurvedRoute(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      // Spline Catmull-Rom a Bezier Cúbico para continuidad suave de la carretera
      final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    return path;
  }

  void _drawHighway(Canvas canvas, Path route) {
    // 1. Resplandor base de la autopista
    final glowPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 7.0 : 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(route, glowPaint);

    // 2. Trazo principal de asfalto
    final roadPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 3.0 : 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(route, roadPaint);

    // 3. Línea central divisoria dorada VIP
    final centerLinePaint = Paint()
      ..color = palette.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 1.0 : 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(route, centerLinePaint);
  }

  void _drawCheckpoints(Canvas canvas, List<Offset> points) {
    for (int i = 0; i < points.length; i++) {
      final wp = CorredorMalaLima.waypoints[i];
      final pos = points[i];
      final isTerminal = wp.esTerminal;
      final isLastReported = wp.codigo == ultimoCheckpointCodigo;
      final isInspected = inspectedWaypoint?.codigo == wp.codigo;

      // Halo pulsante en el último checkpoint reportado
      if (isLastReported) {
        final haloRadius = 14.0 + 8.0 * pulseAnimationValue;
        final haloPaint = Paint()
          ..color = palette.gold.withValues(alpha: 0.35 * (1.0 - pulseAnimationValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(pos, haloRadius, haloPaint);
      }

      // Halo de selección
      if (isInspected) {
        final inspectHalo = Paint()
          ..color = palette.primary.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawCircle(pos, 16.0, inspectHalo);
      }

      if (isTerminal) {
        // Nodos especiales para Terminales (Mala y Grau-Lima)
        final outerPaint = Paint()
          ..color = palette.gold
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, compact ? 7.0 : 9.0, outerPaint);

        final innerPaint = Paint()
          ..color = palette.surface
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, compact ? 4.0 : 5.5, innerPaint);

        final corePaint = Paint()
          ..color = palette.primary
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, compact ? 2.5 : 3.5, corePaint);
      } else {
        // Checkpoints intermedios
        final outerBorder = Paint()
          ..color = palette.surface
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, compact ? 5.5 : 7.0, outerBorder);

        final dotPaint = Paint()
          ..color = isLastReported ? palette.gold : palette.primary
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, compact ? 3.5 : 4.5, dotPaint);
      }

      // Render de Etiquetas
      _drawWaypointLabel(canvas, wp, pos, i % 2 == 0);
    }
  }

  void _drawWaypointLabel(
      Canvas canvas, WaypointCorredor wp, Offset pos, bool alignRight) {
    if (compact && !wp.esTerminal && wp.orden % 3 != 0) {
      // En modo compacto, mostramos terminales y nodos clave cada 3 saltos
      return;
    }

    final isTerminal = wp.esTerminal;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final titleStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: compact ? 9 : 11,
      fontWeight: isTerminal ? FontWeight.w800 : FontWeight.w600,
      color: isTerminal ? palette.gold : palette.textoPrincipal,
      letterSpacing: 0.2,
    );

    final subStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: compact ? 8 : 9,
      color: palette.textoSecundario,
      fontWeight: FontWeight.normal,
    );

    final displayText = wp.nombre;
    final kmText = '[${wp.codigo}] KM ${wp.km.toInt()}';

    textPainter.text = TextSpan(
      children: [
        TextSpan(text: '$displayText\n', style: titleStyle),
        TextSpan(text: kmText, style: subStyle),
      ],
    );
    textPainter.layout();

    final offsetX = alignRight ? 14.0 : -(textPainter.width + 14.0);
    final offsetY = -(textPainter.height / 2);

    // Fondo sutil para legibilidad del texto sobre el radar
    final labelBgRect = Rect.fromLTWH(
      pos.dx + offsetX - 4,
      pos.dy + offsetY - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final bgPaint = Paint()
      ..color = palette.surface.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = isTerminal
          ? palette.gold.withValues(alpha: 0.4)
          : palette.outline.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final rrect = RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4));
    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    textPainter.paint(canvas, Offset(pos.dx + offsetX, pos.dy + offsetY));
  }

  void _drawActiveBuses(Canvas canvas, Path route, Size size) {
    final metrics = route.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final pathMetric = metrics.first;

    for (final dsp in despachosActivos) {
      if (dsp.progreso == null || dsp.progreso! <= 0.0) continue;

      // progreso: 0.0 (Mala) a 1.0 (Lima)
      final clampProgreso = dsp.progreso!.clamp(0.01, 0.99);
      final distance = clampProgreso * pathMetric.length;
      final tangent = pathMetric.getTangentForOffset(distance);

      if (tangent != null) {
        _drawBusPin(canvas, tangent.position, tangent.angle, dsp);
      }
    }
  }

  void _drawBusPin(Canvas canvas, Offset position, double angle, Despacho dsp) {
    canvas.save();
    canvas.translate(position.dx, position.dy);

    // Pin de bus con sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(0, 2), 10, shadowPaint);

    // Pin exterior dorado VIP
    final pinPaint = Paint()
      ..color = palette.gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 9, pinPaint);

    // Pin interior azul marino
    final pinInnerPaint = Paint()
      ..color = palette.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 6.5, pinInnerPaint);

    // Icono / Indicador de dirección
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(0, -3.5)
      ..lineTo(3.0, 2.5)
      ..lineTo(0, 1.2)
      ..lineTo(-3.0, 2.5)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);

    canvas.restore();

    // Etiqueta flotante del Bus con Código y Velocidad
    final busLabel = dsp.unidadCodigo ?? 'VIP-BUS';
    final speedLabel = dsp.velocidadActual != null
        ? '${dsp.velocidadActual!.toInt()} km/h'
        : 'EN RUTA';

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$busLabel\n',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: palette.gold,
            ),
          ),
          TextSpan(
            text: speedLabel,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 8,
              color: palette.textoPrincipal,
            ),
          ),
        ],
      ),
    );
    textPainter.layout();

    final labelRect = Rect.fromLTWH(
      position.dx + 12,
      position.dy - 12,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final bgPaint = Paint()
      ..color = palette.surface.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = palette.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rrect = RRect.fromRectAndRadius(labelRect, const Radius.circular(4));
    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    textPainter.paint(canvas, Offset(position.dx + 16, position.dy - 10));
  }

  @override
  bool shouldRepaint(covariant _CorredorPainter oldDelegate) {
    return oldDelegate.pulseAnimationValue != pulseAnimationValue ||
        oldDelegate.inspectedWaypoint != inspectedWaypoint ||
        oldDelegate.ultimoCheckpointCodigo != ultimoCheckpointCodigo ||
        oldDelegate.despachosActivos.length != despachosActivos.length ||
        oldDelegate.palette != palette;
  }
}
