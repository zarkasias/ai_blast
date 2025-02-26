import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../widgets/animated_block.dart';
import '../widgets/settings_button.dart';
import 'level_screen.dart';
import 'dart:math';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  // Define our game colors
  final List<Color> blockColors = const [
    Color(0xFFFF4B4B), // Red
    Color(0xFF4ECDC4), // Turquoise
    Color(0xFFFFBE0B), // Yellow
    Color(0xFF43CEA2), // Green
    Color(0xFF9B5DE5), // Purple
    Color(0xFF185A9D), // Deep Blue
  ];

  final Random _random = Random();

  Color getRandomColor() {
    return blockColors[_random.nextInt(blockColors.length)];
  }

  // Initialize random colors for each block immediately
  late final List<Color> gridColors = List.generate(
    9,
    (_) => getRandomColor(),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand, // Make stack fill entire screen
        children: [
          // Background Image Layer
          Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/blast-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
          // Gradient Overlay Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7DDFC8).withOpacity(0.1),
                    const Color(0xFF4389C8).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          // Content Layer with SafeArea
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Settings Button
                  const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SettingsButton(
                        color: Color.fromARGB(255, 1, 123, 245),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title Image
                  Image.asset(
                    'assets/images/title.png',
                    width: 400,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 80),
                  // Animated Blocks Grid
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return AnimatedBlock(
                          block: Block(
                            id: index,
                            color: gridColors[index],
                            row: index ~/ 3,
                            col: index % 3,
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                  // Play Button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LevelScreen()),
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + (_controller.value * 0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(180, 255, 255, 255),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF43CEA2).withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'PLAY NOW',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                color: Color(0xFF185A9D),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
