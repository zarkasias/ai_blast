import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/animated_score.dart';
import '../widgets/settings_button.dart';
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
        return Material(
          child: Stack(
            fit: StackFit.expand,
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
              // Animated White Background Layer with 80% opacity
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        Colors.white.withOpacity(0.6),
                        const Color(0xFFF8F9FA).withOpacity(0.6),
                        _backgroundAnimation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFFF8F9FA).withOpacity(0.6),
                        Colors.white.withOpacity(0.6),
                        _backgroundAnimation.value,
                      )!,
                    ],
                  ),
                ),
              ),
              // Main Content
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    return Stack(
                      children: [
                        Column(
                          children: [
                              SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Back Button
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (context) => const LevelScreen()),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Color(0xFF185A9D),
                                          size: 28,
                                        ),
                                      ),
                                      // Score Display
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Level indicator
                                                Text(
                                                  'LEVEL ${gameProvider.currentLevel}',
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF185A9D),
                                                    fontFamily: 'Montserrat',
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                                const SizedBox(height: 28),
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
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                            letterSpacing: 2,
                                                            fontFamily: 'Montserrat',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        AnimatedScore(
                                                          score: gameProvider.score,
                                                          style: const TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF185A9D),
                                                            fontFamily: 'Montserrat',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      height: 50,
                                                      width: 2,
                                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                                      color: const Color.fromARGB(255, 0, 87, 237).withOpacity(0.3),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text(
                                                          'TARGET',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                            letterSpacing: 2,
                                                            fontFamily: 'Montserrat',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${gameProvider.getCurrentLevelTarget()}',
                                                          style: const TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color.fromARGB(255, 0, 112, 8),
                                                            fontFamily: 'Montserrat',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Control Buttons
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
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
                                              color: Color(0xFF185A9D),
                                              size: 28,
                                            ),
                                          ),
                                          // Settings Button
                                          const SettingsButton(
                                            color: Color(0xFF185A9D),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Game Grid
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: GameGrid(),
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
            ],
          ),
        );
      },
    );
  }
} 