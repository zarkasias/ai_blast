import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/settings_button.dart';
import 'game_screen.dart';
import 'intro_screen.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand,  // Make stack fill entire screen
        children: [
          // Background Image Layer
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/blast-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay Layer
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
          // Content Layer with SafeArea
          SafeArea(
            child: Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        // Header with back button and title
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
                          child: Container(
                            color: const Color.fromARGB(180, 255, 255, 255), 
                            height: 70, 
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const IntroScreen()),
                                  );
                                },
                                icon: 
                                  const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFF185A9D),
                                  size: 28,
                                ),
                                
                                 
                              ),
                              const Expanded(
                                child: Text(
                                  'SELECT LEVEL',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF185A9D),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SettingsButton(
                        color: Color.fromARGB(255, 1, 123, 245),
                      ),
                              // Placeholder to balance the back button and settings
                            ],
                          ),
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
                                    color: isUnlocked ? Colors.white : const Color.fromARGB(255, 179, 178, 178),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: isUnlocked ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ] : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Level number
                                      Text(
                                        'Level $level',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: isUnlocked ? const Color(0xFF185A9D) : const Color.fromARGB(255, 244, 241, 241),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Target score
                                      Text(
                                        'Target: ${GameProvider.levelTargets[level]}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isUnlocked ? const Color(0xFF43CEA2) : const Color.fromARGB(255, 244, 241, 241),
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
                                               const Color.fromARGB(255, 221, 220, 220),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                   ], // Settings Button
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 