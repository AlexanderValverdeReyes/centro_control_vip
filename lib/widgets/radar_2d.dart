import 'package:flutter/material.dart';

class Radar2D extends StatelessWidget {
  const Radar2D({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RADAR 2D VECTORIAL DE CORREDOR', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 24),
          Expanded(
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _RadarPainter(),
                ),
                // Mock elements on the radar
                const Positioned(
                  left: 80, top: 40,
                  child: Column(
                    children: [
                      Icon(Icons.directions_bus, color: Color(0xFFD4AF37), size: 28),
                      Text('BUS-101', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.white70))
                    ],
                  ),
                ),
                const Positioned(
                  left: 350, top: 90,
                  child: Column(
                    children: [
                      Icon(Icons.directions_bus, color: Colors.white, size: 24),
                      Text('BUS-204', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.white70))
                    ],
                  ),
                ),
                const Positioned(
                  left: 200, top: 60,
                  child: Column(
                    children: [
                      Icon(Icons.warning, color: Color(0xFF8B0000), size: 20),
                      Text('CHK-SUR', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.redAccent))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B3B6F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = const Color(0xFFD4AF37);

    // Diagonal route line representation
    double startY = size.height * 0.2;
    double endY = size.height * 0.8;
    
    double dashWidth = 15, dashSpace = 10, currentX = 20;
    double currentY = startY;
    
    double slope = (endY - startY) / (size.width - 40);

    while (currentX < size.width - 20) {
      canvas.drawLine(
        Offset(currentX, currentY), 
        Offset(currentX + dashWidth, currentY + (dashWidth * slope)), 
        paint
      );
      currentX += dashWidth + dashSpace;
      currentY += (dashWidth + dashSpace) * slope;
    }

    // Terminals/Checkpoints
    canvas.drawCircle(Offset(20, startY), 6, dotPaint);
    canvas.drawCircle(Offset(size.width - 20, endY), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
