import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';
import 'intro_screen.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF43CEA2),
            Color(0xFF185A9D),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const IntroScreen()),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'SELECT LEVEL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Level Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: GameProvider.levelTargets.length,
                      itemBuilder: (context, index) {
                        final level = index + 1;
                        final isUnlocked = level <= gameProvider.highestUnlockedLevel;
                        final isCompleted = level < gameProvider.highestUnlockedLevel;
                        
                        return GestureDetector(
                          onTap: isUnlocked ? () {
                            gameProvider.startLevel(level);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const GameScreen()),
                            );
                          } : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isUnlocked ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Level number
                                Text(
                                  'Level $level',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked ? const Color(0xFF185A9D) : Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Target score
                                Text(
                                  'Target: ${GameProvider.levelTargets[level]}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isUnlocked ? const Color(0xFF43CEA2) : Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Level status icon
                                Icon(
                                  isCompleted ? Icons.star_rounded :
                                  isUnlocked ? Icons.play_circle_fill_rounded :
                                  Icons.lock_rounded,
                                  size: 32,
                                  color: isCompleted ? Colors.amber :
                                         isUnlocked ? const Color(0xFF43CEA2) :
                                         Colors.white54,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
} 