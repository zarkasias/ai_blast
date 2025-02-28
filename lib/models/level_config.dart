import 'package:flutter/material.dart';
import 'dart:math';

enum BlockType {
  normal,
  bomb,
  rocket,
  rainbow,
  locked,
  ice,      // Block covered in ice that needs two matches to break
  stone,    // Blocks that can't be matched but can be destroyed by special blocks
  portal,   // Teleports matched blocks to another portal
}

enum LevelObjective {
  score,          // Reach target score
  clearBlocks,    // Clear specific number of blocks
  collectItems,   // Collect specific block types
  breakIce,       // Break ice blocks
  surviveMoves,   // Survive with limited moves
  matchBombs,     // Match specific number of bomb blocks
  matchRockets,   // Match specific number of rocket blocks
  matchRainbow,   // Match specific number of rainbow blocks
  usePortals,     // Use portal connections
  createSpecials, // Create special blocks through matches
  chainReaction,  // Create chain reactions
}

class LevelConfig {
  final int levelNumber;
  final int targetScore;
  final int moveLimit;
  final List<LevelObjective> objectives;
  final Map<LevelObjective, int> objectiveTargets;
  
  // Grid configuration
  final int gridRows;
  final int gridCols;
  final List<List<BlockType>>? initialLayout;
  final List<Point<int>>? blockedCells;    // Cells that can't have blocks
  final List<List<Point<int>>>? portalPairs; // Connected portal positions
  
  // Block probabilities
  final double bombProbability;
  final double rocketProbability;
  final double rainbowProbability;
  final double iceProbability;
  final double stoneProbability;
  
  // Available colors and aesthetics
  final List<Color> availableColors;
  final String? backgroundImage;
  final Color? gridBackgroundColor;
  final Map<String, int> rewards;
  
  // Special rules
  final bool gravityEnabled;           // If false, blocks don't fall down
  final bool allowDiagonalMatches;     // If true, diagonal matches are valid
  final int minMatchSize;              // Minimum number of blocks needed for a match
  final bool shuffleOnNoMoves;         // Shuffle board when no moves available
  final int? timeLimit;                // Optional time limit in seconds
  
  // Tutorial and hints
  final String? tutorialText;
  final List<String>? hints;
  final bool showPossibleMoves;        // Highlight possible moves after delay

  const LevelConfig({
    required this.levelNumber,
    required this.targetScore,
    required this.moveLimit,
    this.objectives = const [LevelObjective.score],
    this.objectiveTargets = const {},
    this.gridRows = 8,
    this.gridCols = 8,
    this.initialLayout,
    this.blockedCells,
    this.portalPairs,
    this.bombProbability = 0.0,
    this.rocketProbability = 0.0,
    this.rainbowProbability = 0.0,
    this.iceProbability = 0.0,
    this.stoneProbability = 0.0,
    required this.availableColors,
    this.backgroundImage,
    this.gridBackgroundColor,
    this.rewards = const {},
    this.gravityEnabled = true,
    this.allowDiagonalMatches = false,
    this.minMatchSize = 3,
    this.shuffleOnNoMoves = true,
    this.timeLimit,
    this.tutorialText,
    this.hints,
    this.showPossibleMoves = false,
  });
}

class LevelConfigs {
  static const List<Color> basicColors = [
    Color(0xFF43CEA2), // Turquoise
    Color(0xFF185A9D), // Deep Blue
    Color(0xFFE8537A), // Pink
    Color(0xFFFFB75E), // Orange
    Color(0xFF8E44AD), // Purple
  ];

  static const List<Color> advancedColors = [
    Color(0xFF43CEA2), // Turquoise
    Color(0xFF185A9D), // Deep Blue
    Color(0xFFE8537A), // Pink
    Color(0xFFFFB75E), // Orange
    Color(0xFF8E44AD), // Purple
    Color(0xFFE74C3C), // Red
    Color(0xFF2ECC71), // Green
  ];

  static final List<LevelConfig> levels = [
    // Level 1: Tutorial level - Simple match-3
    LevelConfig(
      levelNumber: 1,
      targetScore: 1000,
      moveLimit: 15,
      availableColors: basicColors.sublist(0, 3),
      objectives: [LevelObjective.score],
      objectiveTargets: {LevelObjective.score: 1000},
      tutorialText: "Match 3 or more blocks of the same color to clear them!",
      hints: ["Try to match blocks at the bottom of the grid first"],
      showPossibleMoves: true,
      rewards: {'coins': 100},
    ),
    
    // Level 2: Introduces one more color and ice blocks
    LevelConfig(
      levelNumber: 2,
      targetScore: 2000,
      moveLimit: 15,
      availableColors: basicColors.sublist(0, 4),
      objectives: [
        LevelObjective.score,
        LevelObjective.breakIce,
        LevelObjective.createSpecials,
      ],
      objectiveTargets: {
        LevelObjective.score: 2000,
        LevelObjective.breakIce: 5,
        LevelObjective.createSpecials: 2,
      },
      iceProbability: 0.15,
      bombProbability: 0.05,
      hints: [
        "Ice blocks need two matches to break completely",
        "Match 4 or more blocks to create special blocks",
      ],
      rewards: {'coins': 150},
    ),
    
    // Level 3: Introduces bomb blocks and blocked cells
    const LevelConfig(
      levelNumber: 3,
      targetScore: 3000,
      moveLimit: 20,
      bombProbability: 0.08,
      availableColors: basicColors,
      blockedCells: [Point(0, 0), Point(0, 7), Point(7, 0), Point(7, 7)],
      objectives: [
        LevelObjective.score,
        LevelObjective.matchBombs,
        LevelObjective.clearBlocks,
      ],
      objectiveTargets: {
        LevelObjective.score: 3000,
        LevelObjective.matchBombs: 3,
        LevelObjective.clearBlocks: 30,
      },
      hints: [
        "Bomb blocks clear all blocks of the same color!",
        "Try to match bomb blocks with large color groups",
      ],
      rewards: {
        'coins': 200,
        'bomb_powerup': 1,
      },
    ),
    
    // Level 4: Portal mechanics
    const LevelConfig(
      levelNumber: 4,
      targetScore: 4000,
      moveLimit: 20,
      bombProbability: 0.05,
      rocketProbability: 0.05,
      availableColors: basicColors,
      portalPairs: [
        [Point(0, 3), Point(7, 3)],
        [Point(3, 0), Point(3, 7)],
      ],
      objectives: [
        LevelObjective.score,
        LevelObjective.usePortals,
        LevelObjective.matchRockets,
      ],
      objectiveTargets: {
        LevelObjective.score: 4000,
        LevelObjective.usePortals: 5,
        LevelObjective.matchRockets: 2,
      },
      hints: [
        "Use portals to create matches across the board!",
        "Rocket blocks clear entire rows or columns",
      ],
      rewards: {
        'coins': 250,
        'rocket_powerup': 1,
      },
    ),
    
    // Level 5: Diagonal matches and rainbow blocks
    LevelConfig(
      levelNumber: 5,
      targetScore: 5000,
      moveLimit: 25,
      bombProbability: 0.05,
      rocketProbability: 0.05,
      rainbowProbability: 0.05,
      availableColors: advancedColors.sublist(0, 6),
      allowDiagonalMatches: true,
      objectives: [
        LevelObjective.score,
        LevelObjective.matchRainbow,
        LevelObjective.chainReaction,
      ],
      objectiveTargets: {
        LevelObjective.score: 5000,
        LevelObjective.matchRainbow: 3,
        LevelObjective.chainReaction: 4,
      },
      hints: [
        "You can now match blocks diagonally!",
        "Rainbow blocks clear all blocks of a random color",
        "Create chain reactions by matching special blocks",
      ],
      rewards: {
        'coins': 300,
        'rainbow_powerup': 1,
      },
    ),
    
    // Level 6: Complex layout with multiple objectives
    const LevelConfig(
      levelNumber: 6,
      targetScore: 7000,
      moveLimit: 25,
      bombProbability: 0.07,
      rocketProbability: 0.07,
      rainbowProbability: 0.07,
      stoneProbability: 0.05,
      availableColors: advancedColors,
      initialLayout: [
        [BlockType.stone, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.stone],
        [BlockType.normal, BlockType.ice, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.ice, BlockType.normal],
        [BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal],
        [BlockType.stone, BlockType.normal, BlockType.normal, BlockType.rainbow, BlockType.rainbow, BlockType.normal, BlockType.normal, BlockType.stone],
        [BlockType.stone, BlockType.normal, BlockType.normal, BlockType.rainbow, BlockType.rainbow, BlockType.normal, BlockType.normal, BlockType.stone],
        [BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal, BlockType.portal, BlockType.normal, BlockType.normal],
        [BlockType.normal, BlockType.ice, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.normal, BlockType.ice, BlockType.normal],
        [BlockType.stone, BlockType.normal, BlockType.normal, BlockType.stone, BlockType.stone, BlockType.normal, BlockType.normal, BlockType.stone],
      ],
      objectives: [
        LevelObjective.score,
        LevelObjective.breakIce,
        LevelObjective.collectItems,
      ],
      objectiveTargets: {
        LevelObjective.score: 7000,
        LevelObjective.breakIce: 4,
        LevelObjective.collectItems: 2,
      },
      hints: [
        "Break the ice blocks to reach your objectives",
        "Use special blocks to clear stone blocks",
        "Create chain reactions with the rainbow blocks",
      ],
      rewards: {
        'coins': 400,
        'bomb_powerup': 1,
        'rocket_powerup': 1,
        'rainbow_powerup': 1,
      },
    ),
    
    // Add more levels with increasing complexity...
  ];
} 