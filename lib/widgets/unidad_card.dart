import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/unidad.dart';

class UnidadCard extends StatelessWidget {
  final Unidad unidad;
  final VoidCallback? onTap;
  final VoidCallback? onDespachar;

  const UnidadCard({
    super.key,
    required this.unidad,
    this.onTap,
    this.onDespachar,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Color badgeColor;
    String badgeText;
    switch (unidad.estado) {
      case 'enAnden':
        badgeColor = palette.primary;
        badgeText = 'EN ANDÉN';
        break;
      case 'enRuta':
        badgeColor = palette.exito;
        badgeText = 'EN RUTA';
        break;
      case 'mantenimiento':
        badgeColor = palette.peligro;
        badgeText = 'MANTENIMIENTO';
        break;
      default:
        badgeColor = palette.textoSecundario;
        badgeText = unidad.estado.toUpperCase();
    }

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header de la tarjeta: Código y Badge de Estado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: palette.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: palette.outline),
                      ),
                      child: Text(
                        unidad.codigo,
                        style: context.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: palette.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          badgeText,
                          style: context.mono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        unidad.placa,
                        style: context.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: palette.textoPrincipal,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Modelo y Tipo de bus
                Text(
                  '${unidad.marca} ${unidad.modelo}',
                  style: context.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textoPrincipal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Año ${unidad.anioFabricacion} • ${unidad.capacidadPasajeros} Pasajeros',
                  style: context.inter(
                    fontSize: 10,
                    color: palette.textoSecundario,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),
                Divider(color: palette.outline, height: 1),
                const SizedBox(height: 8),

                // Telemetría rápida (Presión y Odómetro)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Icon(
                            Icons.speed,
                            size: 13,
                            color: unidad.presionNeumaticosValida
                                ? palette.exito
                                : palette.advertencia,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${unidad.presionNeumaticosPsi.toInt()} PSI',
                            style: context.mono(
                              fontSize: 10,
                              color: unidad.presionNeumaticosValida
                                  ? palette.textoPrincipal
                                  : palette.advertencia,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(unidad.kilometrajeActual / 1000).toStringAsFixed(1)}k km',
                      style: context.mono(
                        fontSize: 10,
                        color: palette.textoSecundario,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),

                // Botón rápido de acción si está en andén
                if (unidad.estado == 'enAnden' && onDespachar != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 26,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: onDespachar,
                      child: Text(
                        'DESPACHAR',
                        style: context.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
