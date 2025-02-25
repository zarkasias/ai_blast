import 'package:flutter/material.dart';
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
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: widget.block.color.withOpacity(0.3 + (_glowAnimation.value * 0.3)),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.block.isSelected 
                      ? widget.block.color.withOpacity(0.8)
                      : widget.block.color,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.3],
                    colors: [
                      widget.block.color,
                      widget.block.color,
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: widget.block.isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                        : null,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 