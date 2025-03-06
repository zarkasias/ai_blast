import 'package:flutter/material.dart';
import 'dart:math';
import '../models/level_config.dart';

/// LevelData is responsible for managing all level configurations in the game.
/// It provides methods to generate levels and helper functions to create new levels.
class LevelData {
  /// Basic color palette for simpler levels
  static const List<Color> basicColors = [
    Color(0xFF43CEA2), // Turquoise
    Color(0xFF185A9D), // Deep Blue
    Color(0xFFE8537A), // Pink
    Color(0xFFFFB75E), // Orange
    Color(0xFF8E44AD), // Purple
  ];

  /// Advanced color palette for more challenging levels
  static const List<Color> advancedColors = [
    ...basicColors,
    Color(0xFFE74C3C), // Red
    Color(0xFF2ECC71), // Green
  ];

  /// Generates and returns all levels in the game
  static List<LevelConfig> generateLevels() {
    return [
      // Level 1: Tutorial level - Simple match-3 (Heart shape)
      createLevel(
        levelNumber: 1,
        targetScore: 1000,
        moveLimit: 18,
        availableColors: basicColors.sublist(0, 3),
        objectives: const [LevelObjective.score],
        objectiveTargets: const {LevelObjective.score: 1000},
        tutorialText: "Match 3 or more blocks of the same color to clear them!",
        hints: const ["Try to match blocks at the bottom of the grid first"],
        showPossibleMoves: true,
        rewards: const {'coins': 100},
        // Heart shape using blocked cells
        blockedCells: const [
          Point(0, 0), Point(0, 7),
          Point(7, 0), Point(7, 7),
        ],
      ),
      
      // Level 2: Gentle introduction to ice blocks
      createLevel(
        levelNumber: 2,
        targetScore: 1500,
        moveLimit: 20,
        availableColors: basicColors.sublist(0, 3),
        objectives: const [
          LevelObjective.score,
          LevelObjective.breakIce,
        ],
        objectiveTargets: const {
          LevelObjective.score: 1500,
          LevelObjective.breakIce: 3,
        },
        iceProbability: 0.10,
        bombProbability: 0.0,
        hints: const [
          "Ice blocks need two matches to break completely",
          "Clear ice blocks to reach your target score",
        ],
        rewards: const {'coins': 150},
        // Simplified layout with fewer blocked cells
        blockedCells: const [
          Point(0, 0), Point(0, 7),
          Point(7, 0), Point(7, 7),
        ],
        initialLayout: const [
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.ice, BlockType.ice, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.ice, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.ice],
          [BlockType.ice, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.ice],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.ice, BlockType.ice, BlockType.normal, BlockType.normal, BlockType.normal],
        ],
      ),
      
      // Level 3: Now introduce special blocks
      createLevel(
        levelNumber: 3,
        targetScore: 2000,
        moveLimit: 20,
        availableColors: basicColors.sublist(0, 4),
        objectives: const [
          LevelObjective.score,
          LevelObjective.matchBombs,
          LevelObjective.clearBlocks,
        ],
        objectiveTargets: const {
          LevelObjective.score: 2000,
          LevelObjective.matchBombs: 3,
          LevelObjective.clearBlocks: 30,
        },
        bombProbability: 0.08,
        hints: const [
          "Bomb blocks clear all blocks of the same color!",
          "Try to match bomb blocks with large color groups",
        ],
        rewards: const {
          'coins': 200,
          'bomb_powerup': 1,
        },
        // Hourglass shape using blocked cells
        blockedCells: const [
          Point(0, 0), Point(0, 1), Point(0, 6), Point(0, 7),
          Point(2, 2), Point(2, 5),
          Point(3, 3), Point(3, 4),
          Point(4, 3), Point(4, 4),
          Point(5, 2), Point(5, 5),
          Point(7, 0), Point(7, 1), Point(7, 6), Point(7, 7),
        ],
        initialLayout: const [
          [BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone],
        ],
      ),
      
      // Level 4: Butterfly shape with portals
      createLevel(
        levelNumber: 4,
        targetScore: 4000,
        moveLimit: 20,
        bombProbability: 0.05,
        rocketProbability: 0.05,
        availableColors: basicColors,
        // Butterfly shape using blocked cells
        blockedCells: const [
          Point(0, 0), Point(0, 1), Point(0, 6), Point(0, 7),
          Point(3, 0), Point(4, 0),
          Point(3, 7), Point(4, 7),
          Point(7, 0), Point(7, 1), Point(7, 6), Point(7, 7),
        ],
        initialLayout: const [
          [BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal],
          [BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone],
          [BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone],
          [BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone],
        ],
        portalPairs: [
          [const Point(2, 2), const Point(2, 5)],
          [const Point(5, 2), const Point(5, 5)],
        ],
        objectives: const [
          LevelObjective.score,
          LevelObjective.usePortals,
          LevelObjective.matchRockets,
        ],
        objectiveTargets: const {
          LevelObjective.score: 4000,
          LevelObjective.usePortals: 5,
          LevelObjective.matchRockets: 2,
        },
        hints: const [
          "Use portals to create matches across the board!",
          "Rocket blocks clear entire rows or columns",
        ],
        rewards: const {
          'coins': 250,
          'rocket_powerup': 1,
        },
      ),
      
      // Level 5: Diamond maze with rainbow blocks
      createLevel(
        levelNumber: 5,
        targetScore: 5000,
        moveLimit: 25,
        bombProbability: 0.05,
        rocketProbability: 0.05,
        rainbowProbability: 0.05,
        availableColors: advancedColors.sublist(0, 6),
        allowDiagonalMatches: true,
        // Diamond maze using blocked cells
        blockedCells: const [
          Point(0, 0), Point(0, 1), Point(0, 6), Point(0, 7),
          Point(1, 0), Point(1, 7),
          Point(2, 2), Point(2, 5),
          Point(3, 3), Point(3, 4),
          Point(4, 3), Point(4, 4),
          Point(5, 2), Point(5, 5),
          Point(6, 0), Point(6, 7),
          Point(7, 0), Point(7, 1), Point(7, 6), Point(7, 7),
        ],
        initialLayout: const [
          [BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone],
          [BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone],
          [BlockType.normal, BlockType.normal, BlockType.stone, BlockType.rainbow, BlockType.rainbow, BlockType.stone, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.rainbow, BlockType.stone, BlockType.stone, BlockType.rainbow, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.rainbow, BlockType.stone, BlockType.stone, BlockType.rainbow, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.stone, BlockType.rainbow, BlockType.rainbow, BlockType.stone, BlockType.normal, BlockType.normal],
          [BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone],
          [BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone],
        ],
        objectives: const [
          LevelObjective.score,
          LevelObjective.matchRainbow,
          LevelObjective.chainReaction,
        ],
        objectiveTargets: const {
          LevelObjective.score: 5000,
          LevelObjective.matchRainbow: 3,
          LevelObjective.chainReaction: 4,
        },
        hints: const [
          "You can now match blocks diagonally!",
          "Rainbow blocks clear all blocks of a random color",
          "Create chain reactions by matching special blocks",
        ],
        rewards: const {
          'coins': 300,
          'rainbow_powerup': 1,
        },
      ),
      
      // Level 6: Castle fortress layout with all mechanics
      createLevel(
        levelNumber: 6,
        targetScore: 6000,
        moveLimit: 30,
        bombProbability: 0.07,
        rocketProbability: 0.07,
        rainbowProbability: 0.07,
        stoneProbability: 0.05,
        availableColors: advancedColors,
        // Castle fortress layout using blocked cells
        blockedCells: const [
          Point(0, 0), Point(0, 2), Point(0, 5), Point(0, 7),
          Point(2, 0), Point(2, 7),
          Point(3, 3), Point(3, 4),
          Point(4, 3), Point(4, 4),
          Point(5, 0), Point(5, 7),
          Point(7, 0), Point(7, 2), Point(7, 5), Point(7, 7),
        ],
        initialLayout: const [
          [BlockType.stone, BlockType.normal, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.normal, BlockType.stone],
          [BlockType.normal, BlockType.ice, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.ice, BlockType.normal],
          [BlockType.stone, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.stone],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.normal, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.normal],
          [BlockType.stone, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.stone],
          [BlockType.normal, BlockType.ice, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.ice, BlockType.normal],
          [BlockType.stone, BlockType.normal, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.normal, BlockType.stone],
        ],
        portalPairs: [
          [const Point(2, 2), const Point(2, 5)],
          [const Point(5, 2), const Point(5, 5)],
        ],
        objectives: const [
          LevelObjective.score,
          LevelObjective.breakIce,
          LevelObjective.matchBombs,
          LevelObjective.matchRainbow,
        ],
        objectiveTargets: const {
          LevelObjective.score: 6000,
          LevelObjective.breakIce: 8,
          LevelObjective.matchBombs: 4,
          LevelObjective.matchRainbow: 3,
        },
        hints: const [
          "Stone blocks can only be destroyed by special blocks",
          "Use special blocks strategically to clear obstacles",
          "Connect through portals to create powerful combinations",
        ],
        rewards: const {
          'coins': 400,
          'bomb_powerup': 1,
          'rainbow_powerup': 1,
        },
      ),
    ];
  }

  /// Helper method to create a new level with all available configuration options
  static LevelConfig createLevel({
    required int levelNumber,
    required int targetScore,
    required int moveLimit,
    required List<Color> availableColors,
    required List<LevelObjective> objectives,
    required Map<LevelObjective, int> objectiveTargets,
    double bombProbability = 0.0,
    double rocketProbability = 0.0,
    double rainbowProbability = 0.0,
    double iceProbability = 0.0,
    double stoneProbability = 0.0,
    List<Point<int>>? blockedCells,
    List<List<Point<int>>>? portalPairs,
    List<List<BlockType>>? initialLayout,
    List<String>? hints,
    Map<String, int> rewards = const {},
    bool allowDiagonalMatches = false,
    bool showPossibleMoves = false,
    String? tutorialText,
    int gridRows = 8,
    int gridCols = 8,
    bool gravityEnabled = true,
    bool shuffleOnNoMoves = true,
    int minMatchSize = 3,
    int? timeLimit,
  }) {
    return LevelConfig(
      levelNumber: levelNumber,
      targetScore: targetScore,
      moveLimit: moveLimit,
      availableColors: availableColors,
      objectives: objectives,
      objectiveTargets: objectiveTargets,
      bombProbability: bombProbability,
      rocketProbability: rocketProbability,
      rainbowProbability: rainbowProbability,
      iceProbability: iceProbability,
      stoneProbability: stoneProbability,
      blockedCells: blockedCells,
      portalPairs: portalPairs,
      initialLayout: initialLayout,
      hints: hints,
      rewards: rewards,
      allowDiagonalMatches: allowDiagonalMatches,
      showPossibleMoves: showPossibleMoves,
      tutorialText: tutorialText,
      gridRows: gridRows,
      gridCols: gridCols,
      gravityEnabled: gravityEnabled,
      shuffleOnNoMoves: shuffleOnNoMoves,
      minMatchSize: minMatchSize,
      timeLimit: timeLimit,
    );
  }
} 