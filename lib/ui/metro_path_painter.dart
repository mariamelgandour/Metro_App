import 'dart:ui';
import 'package:flutter/material.dart';
import '../Models/Station.dart';

class MetroPathPainter extends CustomPainter {
  final List<Station> shortestPath;
  final List<List<Station>> allPaths;

  MetroPathPainter({required this.shortestPath, required this.allPaths});

  @override
  void paint(Canvas canvas, Size size) {
    final paintPath =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final paintShortest =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    for (var path in allPaths) {
      _drawPath(canvas, path, paintPath);
    }

    if (shortestPath.isNotEmpty) {
      _drawPath(canvas, shortestPath, paintShortest);
    }
  }

  void _drawPath(Canvas canvas, List<Station> path, Paint paint) {
    final points =
        path
            .map((s) => Offset(s.x, s.y)) // Directly use x and y as Offset
            .toList();

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
