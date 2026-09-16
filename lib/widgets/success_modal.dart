import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/despacho.dart';

class SuccessModal extends StatelessWidget {
  final Despacho despacho;

  const SuccessModal({
    super.key,
    required this.despacho,
  });

  static Future<void> show(BuildContext context, Despacho despacho) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SuccessModal(despacho: despacho),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: palette.gold, width: 1.5),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de Éxito Dorado
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: palette.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: palette.gold, width: 2),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: palette.gold,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              'DESPACHO REGISTRADO CON ÉXITO',
              style: context.mono(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: palette.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Transacción atómica confirmada en base de datos local',
              style: context.inter(
                fontSize: 12,
                color: palette.textoSecundario,
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de Detalles y Hash
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CÓDIGO DE DESPACHO',
                        style: context.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: palette.textoSecundario,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: palette.primary),
                        ),
                        child: Text(
                          despacho.codigo,
                          style: context.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: palette.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(context, 'Ruta:', despacho.rutaNombre ?? despacho.rutaId),
                  _buildDetailRow(context, 'Unidad:', despacho.unidadCodigo ?? despacho.unidadId),
                  _buildDetailRow(context, 'Conductor:', despacho.conductorNombre ?? despacho.conductorId),
                  _buildDetailRow(context, 'Andén:', despacho.andenNombre ?? despacho.andenId),
                  _buildDetailRow(context, 'Salida Programada:', despacho.salidaProg),
                  const SizedBox(height: 10),
                  Divider(color: palette.outline, height: 1),
                  const SizedBox(height: 10),

                  // Hash de Integridad SHA-256
                  Text(
                    'INTEGRIDAD CRIPTOGRÁFICA (SHA-256)',
                    style: context.mono(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: palette.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: palette.outline),
                    ),
                    child: SelectableText(
                      despacho.hashIntegridad ?? 'PENDIENTE_GENERACION',
                      style: context.mono(
                        fontSize: 9,
                        color: palette.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Estado de Transacción y Sincronización
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.exito.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: palette.exito),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 11, color: palette.exito),
                            const SizedBox(width: 4),
                            Text(
                              'COMMIT OK',
                              style: context.mono(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: palette.exito,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: palette.tertiary),
                        ),
                        child: Text(
                          'EN COLA OUTBOX (SYNC PENDING)',
                          style: context.mono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: palette.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón Aceptar
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'ACEPTAR Y VOLVER',
                  style: context.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.inter(fontSize: 11, color: palette.textoSecundario)),
          Text(
            value,
            style: context.mono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: palette.textoPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}
