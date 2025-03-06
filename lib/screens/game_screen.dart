import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/animated_score.dart';
import '../widgets/settings_button.dart';
import '../widgets/level_objectives.dart';
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
                                            icon: Image.asset(
                                              'assets/icons/info/info_64px.png',
                                              width: 28,
                                              height: 28,
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

                            // Level Objectives
                            if (gameProvider.currentLevelConfig.objectives.length > 1)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
                                child: LevelObjectives(
                                  objectiveProgress: gameProvider.objectiveProgress,
                                  objectiveTargets: gameProvider.currentLevelConfig.objectiveTargets,
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

                            // Moves Left Counter
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.swap_horiz_rounded,
                                    color: Color(0xFF185A9D),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Moves Left: ${gameProvider.movesLeft}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF185A9D),
                                    ),
                                  ),
                                ],
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
                                margin: const EdgeInsets.all(32),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sentiment_dissatisfied_rounded,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'GAME OVER',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Final Score: ${gameProvider.score}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (gameProvider.currentLevelConfig.objectives.length > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: LevelObjectives(
                                          objectiveProgress: gameProvider.objectiveProgress,
                                          objectiveTargets: gameProvider.currentLevelConfig.objectiveTargets,
                                          isUnlocked: true,
                                        ),
                                      ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            gameProvider.startLevel(gameProvider.currentLevel);
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Icon(Icons.refresh_rounded),
                                          label: const Text('RETRY LEVEL'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(builder: (context) => const LevelScreen()),
                                            );
                                          },
                                          icon: const Icon(Icons.grid_view_rounded),
                                          label: const Text('LEVEL SELECT'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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