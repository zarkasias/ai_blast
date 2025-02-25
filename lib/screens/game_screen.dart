import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/animated_score.dart';
import '../services/audio_service.dart';
import 'intro_screen.dart';
import 'level_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  bool _showTutorial = false;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    // Set system overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    // Initialize background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );

    // Initialize a new game when screen is created
    Future.microtask(() {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.initializeGame();
    });
    
    // Wait for GameProvider to be initialized before showing tutorial
    Future.microtask(() async {
      if (mounted) {
        final gameProvider = Provider.of<GameProvider>(context, listen: false);
        // Wait for initialization
        while (!gameProvider.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;
        }
        if (gameProvider.shouldShowTutorial) {
          setState(() {
            _showTutorial = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF43CEA2),
                  const Color(0xFF3BC7B9),
                  _backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFF185A9D),
                  const Color(0xFF1B4B8A),
                  _backgroundAnimation.value,
                )!,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        // Top Bar Section with Status Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.64),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: [
                                  // Back button and control buttons row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Back Button
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (context) => const IntroScreen()),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Color.fromARGB(255, 1, 130, 89),
                                          size: 28,
                                        ),
                                      ),
                                      // Control Buttons
                                      Row(
                                        children: [
                                          // Help Button
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              setState(() {
                                                _showTutorial = true;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.help_outline_rounded,
                                              color: Color.fromARGB(255, 1, 130, 89),
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          // Sound Toggle Button
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              final audioService = AudioService();
                                              audioService.toggleSound();
                                              setState(() {});
                                            },
                                            icon: Icon(
                                              AudioService().isSoundEnabled
                                                  ? Icons.volume_up_rounded
                                                  : Icons.volume_off_rounded,
                                              color: const Color.fromARGB(255, 1, 130, 89),
                                              size: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  // Score Display
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Level indicator
                                        Text(
                                          'LEVEL ${gameProvider.currentLevel}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 1, 130, 89),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Score and target
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'SCORE',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                                AnimatedScore(
                                                  score: gameProvider.score,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(255, 1, 130, 89),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 30,
                                              width: 2,
                                              margin: const EdgeInsets.symmetric(horizontal: 12),
                                              color: Colors.grey.withOpacity(0.3),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'TARGET',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                                Text(
                                                  '${gameProvider.getCurrentLevelTarget()}',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(255, 1, 130, 89),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Game Grid
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: const GameGrid(),
                            ),
                          ),
                        ),

                        // Warning Indicator
                        if (gameProvider.isNearGameOver && !gameProvider.isGameOver)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Few Moves Left!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),

                    // Game Over Overlay
                    if (gameProvider.isGameOver)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            margin: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  gameProvider.hasReachedLevelTarget() ? Icons.star_rounded : Icons.emoji_events_rounded,
                                  color: gameProvider.hasReachedLevelTarget() ? Colors.amber : const Color(0xFF43CEA2),
                                  size: 64,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  gameProvider.hasReachedLevelTarget() ? 'LEVEL ${gameProvider.currentLevel} COMPLETE!' : 'GAME OVER',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF185A9D),
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Final Score: ${gameProvider.score}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Color(0xFF43CEA2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (gameProvider.hasReachedLevelTarget() && gameProvider.currentLevel < GameProvider.levelTargets.length)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Next Level Target: ${GameProvider.levelTargets[gameProvider.currentLevel + 1]}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF185A9D),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 32),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Continue or Play Again Button
                                    if (gameProvider.hasReachedLevelTarget() && gameProvider.currentLevel < GameProvider.levelTargets.length)
                                      GestureDetector(
                                        onTap: () {
                                          gameProvider.startLevel(gameProvider.currentLevel + 1);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF43CEA2),
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF43CEA2).withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'NEXT LEVEL',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      GestureDetector(
                                        onTap: () => gameProvider.initializeGame(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF43CEA2),
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF43CEA2).withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'PLAY AGAIN',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    // Level Select Button
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (context) => const LevelScreen()),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color(0xFF185A9D),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Text(
                                          'LEVEL SELECT',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF185A9D),
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Tutorial Overlay
                    if (_showTutorial)
                      TutorialOverlay(
                        onClose: () {
                          setState(() {
                            _showTutorial = false;
                          });
                          if (context.read<GameProvider>().shouldShowTutorial) {
                            context.read<GameProvider>().markTutorialAsSeen();
                          }
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
} 