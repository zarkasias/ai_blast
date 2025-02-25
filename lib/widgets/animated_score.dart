import 'package:flutter/material.dart';

class AnimatedScore extends StatefulWidget {
  final int score;
  final TextStyle style;

  const AnimatedScore({
    Key? key,
    required this.score,
    required this.style,
  }) : super(key: key);

  @override
  State<AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<AnimatedScore> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _oldScore;
  late int _displayScore;

  @override
  void initState() {
    super.initState();
    _oldScore = widget.score;
    _displayScore = widget.score;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.addListener(() {
      setState(() {
        _displayScore = _oldScore + ((_animation.value * (widget.score - _oldScore)).round());
      });
    });
  }

  @override
  void didUpdateWidget(AnimatedScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      _oldScore = _displayScore;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_displayScore',
      style: widget.style,
    );
  }
} 