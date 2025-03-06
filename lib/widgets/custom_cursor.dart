import 'package:flutter/material.dart';

class CustomCursor extends StatefulWidget {
  final Widget child;

  const CustomCursor({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<CustomCursor> createState() => _CustomCursorState();
}

class _CustomCursorState extends State<CustomCursor> {
  Offset _mousePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.none,
      onHover: (event) {
        setState(() {
          _mousePosition = event.position;
        });
      },
      child: Stack(
        children: [
          widget.child,
          if (_mousePosition != Offset.zero)
            Positioned(
              left: _mousePosition.dx - 16,  // Center the cursor (half of width)
              top: _mousePosition.dy - 16,   // Center the cursor (half of height)
              child: Image.asset(
                'assets/icons/cursor/cursor_gold_64px.png',
                width: 32,
                height: 32,
              ),
            ),
        ],
      ),
    );
  }
} 