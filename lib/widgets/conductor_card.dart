import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/conductor.dart';

class ConductorCard extends StatelessWidget {
  final Conductor conductor;
  final VoidCallback? onTap;

  const ConductorCard({
    super.key,
    required this.conductor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Color badgeColor;
    String badgeText;
    switch (conductor.estado) {
      case 'DESCANSADO':
        badgeColor = palette.exito;
        badgeText = 'DESCANSADO';
        break;
      case 'EN_RUTA':
        badgeColor = palette.primary;
        badgeText = 'EN RUTA';
        break;
      case 'DESCANSO_MEDICO':
        badgeColor = palette.peligro;
        badgeText = 'MEDICO';
        break;
      default:
        badgeColor = palette.textoSecundario;
        badgeText = conductor.estado;
    }

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: conductor.licenciaVencida
              ? palette.peligro
              : conductor.licenciaPorVencer
                  ? palette.advertencia
                  : palette.outline,
        ),
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
                // Header: Código y Estado
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
                        conductor.codigo,
                        style: context.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: palette.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
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
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'DNI: ${conductor.dni}',
                      style: context.mono(
                        fontSize: 10,
                        color: palette.textoSecundario,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Nombres y Apellidos
                Text(
                  conductor.nombreCompleto,
                  style: context.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textoPrincipal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Licencia ${conductor.licenciaCategoria} • ${conductor.licenciaNumero}',
                  style: context.inter(
                    fontSize: 11,
                    color: palette.textoSecundario,
                  ),
                ),

                const SizedBox(height: 8),
                Divider(color: palette.outline, height: 1),
                const SizedBox(height: 8),

                // Vigencia y Alertas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 13,
                          color: palette.textoSecundario,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${conductor.horasDescansoAcumuladas}h descanso',
                          style: context.mono(
                            fontSize: 10,
                            color: palette.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                    if (conductor.licenciaVencida)
                      Text(
                        'LIC. VENCIDA',
                        style: context.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: palette.peligro,
                        ),
                      )
                    else if (conductor.licenciaPorVencer)
                      Text(
                        'VENCE PRONTO',
                        style: context.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: palette.advertencia,
                        ),
                      )
                    else
                      Text(
                        'Vence: ${conductor.licenciaVigencia.split("T").first}',
                        style: context.mono(
                          fontSize: 10,
                          color: palette.textoSecundario,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
