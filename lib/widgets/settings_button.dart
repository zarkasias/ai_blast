import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';

class SettingsButton extends StatelessWidget {
  final Color? color;
  
  const SettingsButton({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
      },
      icon: Stack(
        alignment: Alignment.center,
        children: [
           const Icon(
            Icons.settings_rounded,
            color: Colors.white,
            size: 36,
          ),
          Icon(
            Icons.settings_rounded,
            color: color ?? const Color(0xFF185A9D),
            size: 28,
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Color color;

  CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => color != oldDelegate.color;
} 