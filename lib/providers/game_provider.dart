import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';

class Block {
  final int id;
  final Color color;
  bool isSelected;
  final int row;
  final int col;

  Block({
    required this.id,
    required this.color,
    this.isSelected = false,
    required this.row,
    required this.col,
  });

  Block copyWith({
    int? id,
    Color? color,
    bool? isSelected,
    int? row,
    int? col,
  }) {
    return Block(
      id: id ?? this.id,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }
}

class GameProvider extends ChangeNotifier {
  static const int gridSize = 8;
  late List<List<Block?>> grid;
  int score = 0;
  int currentLevel = 1;
  int highestUnlockedLevel = 1;
  bool isGameOver = false;
  bool isNearGameOver = false;
  List<Block> selectedBlocks = [];
  int movesWithoutMatch = 0;
  bool shouldShowTutorial = true;
  bool isInitialized = false;
  final AudioService _audioService = AudioService();
  
  // Level configuration
  static const Map<int, int> levelTargets = {
    1: 1000,   // Level 1: Score 1000 to advance
    2: 2500,   // Level 2: Score 2500 to advance
    3: 5000,   // Level 3: Score 5000 to advance
    4: 10000,  // Level 4: Score 10000 to advance
    5: 20000,  // Level 5: Score 20000 to advance
  };

  // Available colors for blocks
  final List<Color> blockColors = const [
    Color(0xFFFF4B4B),  // Red
    Color(0xFF4ECDC4),  // Turquoise
    Color(0xFFFFBE0B),  // Yellow
    Color(0xFF43CEA2),  // Green
    Color(0xFF9B5DE5),  // Purple
    Color(0xFF185A9D),  // Deep Blue
  ];

  final Random _random = Random();

  Color getRandomColor() {
    if (blockColors.isEmpty) {
      // Fallback colors in case the list is somehow empty
      return const Color(0xFF43CEA2);
    }
    return blockColors[_random.nextInt(blockColors.length)];
  }

  int getCurrentLevelTarget() {
    return levelTargets[currentLevel] ?? 999999; // Return a high number for levels beyond the map
  }

  bool hasReachedLevelTarget() {
    return score >= getCurrentLevelTarget();
  }

  Future<void> _initialize() async {
    try {
      await Future.wait([
        SharedPreferences.getInstance(),
        _audioService.initialize(),
      ]).then((results) {
        final prefs = results[0] as SharedPreferences;
        shouldShowTutorial = prefs.getBool('has_seen_tutorial') != true;
        highestUnlockedLevel = prefs.getInt('highest_unlocked_level') ?? 1;
      });
      
      isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initialization: $e');
      isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> markTutorialAsSeen() async {
    if (!isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_tutorial', true);
      shouldShowTutorial = false;
      notifyListeners();
    } catch (e) {
      // If there's an error saving the preference, just update the local state
      shouldShowTutorial = false;
      notifyListeners();
    }
  }

  void startLevel(int level) {
    if (level < 1 || level > levelTargets.length) return;
    currentLevel = level;
    initializeGame(false);
  }

  void initializeGame([bool isNewGame = true]) {
    // Clear any existing selections
    selectedBlocks = [];
    
    // Reset the grid with new random blocks
    grid = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        return Block(
          id: row * gridSize + col,
          color: getRandomColor(),
          row: row,
          col: col,
        );
      });
    });

    // Reset game state variables
    if (isNewGame) {
      currentLevel = 1;
    }
    score = 0;
    isGameOver = false;
    isNearGameOver = false;
    movesWithoutMatch = 0;

    // Check initial game state to ensure there are valid moves
    checkGameState();
    
    // If no valid moves are available, recursively try again
    if (isGameOver) {
      initializeGame(isNewGame);
      return;
    }

    // Start background music if it's not already playing
    _audioService.startBackgroundMusic();

    notifyListeners();
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highest_unlocked_level', highestUnlockedLevel);
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void advanceLevel() {
    if (currentLevel < levelTargets.length) {
      // Update highest unlocked level if needed
      if (currentLevel >= highestUnlockedLevel) {
        highestUnlockedLevel = currentLevel + 1;
        _saveProgress();
      }
      currentLevel++;
      notifyListeners();
    }
  }

  void clearSelection() {
    for (var block in selectedBlocks) {
      if (grid[block.row][block.col] != null) {
        grid[block.row][block.col] = grid[block.row][block.col]!.copyWith(isSelected: false);
      }
    }
    selectedBlocks.clear();
    notifyListeners();
  }

  bool areBlocksAdjacent(Block a, Block b) {
    return (a.row == b.row && (a.col - b.col).abs() == 1) ||
        (a.col == b.col && (a.row - b.row).abs() == 1);
  }

  List<Point<int>> findMatchingGroup(int row, int col) {
    if (grid[row][col] == null) return [];
    final Color color = grid[row][col]!.color;
    final Set<Point<int>> group = {Point(row, col)};
    final List<Point<int>> toCheck = [Point(row, col)];

    while (toCheck.isNotEmpty) {
      final Point<int> current = toCheck.removeLast();
      // Check all adjacent blocks
      for (final Point<int> offset in [Point(-1, 0), Point(1, 0), Point(0, -1), Point(0, 1)]) {
        final int newRow = current.x + offset.x;
        final int newCol = current.y + offset.y;
        
        if (newRow >= 0 && newRow < gridSize && 
            newCol >= 0 && newCol < gridSize &&
            grid[newRow][newCol]?.color == color &&
            !group.contains(Point(newRow, newCol))) {
          group.add(Point(newRow, newCol));
          toCheck.add(Point(newRow, newCol));
        }
      }
    }
    
    return group.length >= 3 ? group.toList() : [];
  }

  void selectBlock(int row, int col) {
    if (isGameOver || grid[row][col] == null) return;

    final block = grid[row][col]!;
    final List<Point<int>> matchingGroup = findMatchingGroup(row, col);
    
    if (matchingGroup.isEmpty) {
      // No valid group found, clear any existing selection
      clearSelection();
      return;
    }

    // Clear any existing selection
    clearSelection();

    // Add all blocks in the matching group to selectedBlocks
    selectedBlocks = matchingGroup.map((point) {
      final block = grid[point.x][point.y]!;
      grid[point.x][point.y] = block.copyWith(isSelected: true);
      return block;
    }).toList();

    _audioService.playSelectSound();

    // Remove the blocks immediately since we've confirmed it's a valid group
    removeSelectedBlocks();
    
    notifyListeners();
  }

  void removeSelectedBlocks() {
    // Only remove blocks if we have at least 3
    if (selectedBlocks.length < 3) return;

    // Remove selected blocks and update score
    for (var block in selectedBlocks) {
      grid[block.row][block.col] = null;
    }

    // Update score - more blocks = higher multiplier
    int multiplier = selectedBlocks.length - 2; // Start multiplier at 1 for 3 blocks
    int basePoints = 10;
    int levelBonus = currentLevel; // Add level bonus
    score += selectedBlocks.length * basePoints * multiplier * levelBonus;

    _audioService.playMatchSound();
    selectedBlocks.clear();
    movesWithoutMatch = 0;

    // Check if we've reached the level target
    if (hasReachedLevelTarget()) {
      advanceLevel();
    }

    // Apply gravity with animation delay
    Future.delayed(const Duration(milliseconds: 300), () {
      applyGravity();
      
      // Fill empty spaces after gravity
      Future.delayed(const Duration(milliseconds: 300), () {
        fillEmptySpaces();
        checkGameState();
        notifyListeners();
      });
    });
    
    notifyListeners();
  }

  void applyGravity() {
    for (int col = 0; col < gridSize; col++) {
      int writePos = gridSize - 1;
      
      for (int row = gridSize - 1; row >= 0; row--) {
        if (grid[row][col] != null) {
          if (writePos != row) {
            grid[writePos][col] = grid[row][col]!.copyWith(row: writePos);
            grid[row][col] = null;
          }
          writePos--;
        }
      }
    }
    notifyListeners();
  }

  void fillEmptySpaces() {
    for (int col = 0; col < gridSize; col++) {
      for (int row = gridSize - 1; row >= 0; row--) {
        if (grid[row][col] == null) {
          grid[row][col] = Block(
            id: _random.nextInt(10000),
            color: getRandomColor(),
            row: row,
            col: col,
          );
        }
      }
    }
    notifyListeners();
  }

  bool hasMatchingNeighbors(int row, int col) {
    if (grid[row][col] == null) return false;
    final Color color = grid[row][col]!.color;
    
    // Check horizontal groups
    int horizontalCount = 1;
    // Check left
    for (int i = col - 1; i >= 0 && grid[row][i]?.color == color; i--) {
      horizontalCount++;
    }
    // Check right
    for (int i = col + 1; i < gridSize && grid[row][i]?.color == color; i++) {
      horizontalCount++;
    }
    if (horizontalCount >= 3) return true;

    // Check vertical groups
    int verticalCount = 1;
    // Check up
    for (int i = row - 1; i >= 0 && grid[i][col]?.color == color; i--) {
      verticalCount++;
    }
    // Check down
    for (int i = row + 1; i < gridSize && grid[i][col]?.color == color; i++) {
      verticalCount++;
    }
    if (verticalCount >= 3) return true;

    return false;
  }

  // Enhanced game state checking
  void checkGameState() {
    int possibleMoves = 0;
    
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (hasMatchingNeighbors(row, col)) {
          possibleMoves++;
          // Early exit if we find any valid moves
          if (possibleMoves >= 1) {
            isNearGameOver = false;
            isGameOver = false;
            return;
          }
        }
      }
    }

    // If we get here, no valid moves were found
    isGameOver = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}