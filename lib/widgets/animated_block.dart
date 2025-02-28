import 'package:flutter/material.dart';
import 'dart:math';
import '../providers/game_provider.dart';

class AnimatedBlock extends StatefulWidget {
  final Block block;
  final VoidCallback onTap;

  const AnimatedBlock({
    Key? key,
    required this.block,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedBlock> createState() => _AnimatedBlockState();
}

class _AnimatedBlockState extends State<AnimatedBlock> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.block.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.block.isSelected != oldWidget.block.isSelected) {
      if (widget.block.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.block.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.block.color.withOpacity(0.3),
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base block design
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.block.color.withOpacity(0.7),
                        widget.block.color,
                      ],
                    ),
                  ),
                ),
              ),

              // Special block overlays
              if (widget.block.isBomb)
                Center(
                  child: Icon(
                    Icons.stars_rounded,
                    color: widget.block.color == const Color(0xFFFFB75E) ? const Color(0xFF185A9D) : const Color(0xFFFFB75E),
                    size: 24,
                  ),
                )
              else if (widget.block.isRocket)
                Center(
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    color: widget.block.color == const Color(0xFFFFB75E) ? const Color(0xFF185A9D) : const Color(0xFFFFB75E),
                    size: 24,
                  ),
                )
              else if (widget.block.isRainbow)
                Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: widget.block.color == const Color(0xFFFFB75E) ? const Color(0xFF185A9D) : const Color(0xFFFFB75E),
                    size: 24,
                  ),
                )
              else if (widget.block.isPortal)
                Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.blur_circular_rounded,
                        color: widget.block.color == const Color(0xFFFFB75E) ? const Color(0xFF185A9D) : const Color(0xFFFFB75E),
                        size: 24,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),

              // Ice layer overlay
              if (widget.block.hasIce)
                Stack(
                  children: [
                    // Ice texture
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    // Ice cracks (if one layer remaining)
                    if (widget.block.iceLayer == 1)
                      CustomPaint(
                        painter: IceCrackPainter(),
                      ),
                    // Ice crystal icon
                    const Center(
                      child: Icon(
                        Icons.ac_unit_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

              // Selection overlay
              if (widget.block.isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class IceCrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw random cracks
    final random = Random();
    for (int i = 0; i < 3; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      path.moveTo(startX, startY);
      
      for (int j = 0; j < 3; j++) {
        final endX = startX + (random.nextDouble() - 0.5) * 20;
        final endY = startY + (random.nextDouble() - 0.5) * 20;
        path.lineTo(endX, endY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 