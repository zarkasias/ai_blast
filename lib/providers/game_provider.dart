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
  final bool isBomb;

  Block({
    required this.id,
    required this.color,
    this.isSelected = false,
    required this.row,
    required this.col,
    this.isBomb = false,
  });

  Block copyWith({
    int? id,
    Color? color,
    bool? isSelected,
    int? row,
    int? col,
    bool? isBomb,
  }) {
    return Block(
      id: id ?? this.id,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
      row: row ?? this.row,
      col: col ?? this.col,
      isBomb: isBomb ?? this.isBomb,
    );
  }
}

class GameProvider extends ChangeNotifier {
  static const int gridSize = 8;
  static const double bombProbability = 0.03; // 3% chance for a bomb block
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
  final AudioService _audioService;
  
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
    Color.fromARGB(255, 3, 139, 57),  // Dark Green
    Color(0xFF9B5DE5),  // Purple
    Color(0xFF185A9D),  // Deep Blue
  ];

  final Random _random = Random();

  GameProvider({required AudioService audioService}) : _audioService = audioService {
    _initialize();
  }

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
      debugPrint('GameProvider: Starting initialization...');
      
      // Load preferences
      final prefs = await SharedPreferences.getInstance();
      shouldShowTutorial = prefs.getBool('has_seen_tutorial') != true;
      
      // Reset highest unlocked level to 1 if not found in preferences
      highestUnlockedLevel = 1;
      try {
        final savedLevel = prefs.getInt('highest_unlocked_level');
        if (savedLevel != null && savedLevel > 0 && savedLevel <= levelTargets.length) {
          highestUnlockedLevel = savedLevel;
        } else {
          // If invalid saved level, reset it
          await prefs.setInt('highest_unlocked_level', 1);
        }
      } catch (e) {
        debugPrint('GameProvider: Error loading highest level: $e');
        // Reset to level 1 if there's an error
        await prefs.setInt('highest_unlocked_level', 1);
      }
      
      // Initialize the game
      initializeGame();
      
      isInitialized = true;
      notifyListeners();
      debugPrint('GameProvider: Initialization complete with highest level: $highestUnlockedLevel');
    } catch (e) {
      debugPrint('GameProvider: Error during initialization: $e');
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
    
    // Set the level first
    currentLevel = level;
    
    // Then initialize the game with the correct level
    initializeGame(false);
    
    // Notify listeners to update UI
    notifyListeners();
  }

  Block createBlock(int row, int col) {
    final color = getRandomColor();
    final shouldBeBomb = _random.nextDouble() < bombProbability;
    
    return Block(
      id: row * gridSize + col,
      color: color,
      row: row,
      col: col,
      isBomb: shouldBeBomb,
    );
  }

  void initializeGame([bool isNewGame = true]) {
    // Clear any existing selections
    selectedBlocks = [];
    
    // Reset the grid with new random blocks
    grid = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        return createBlock(row, col);
      });
    });

    // Reset game state variables
    if (isNewGame) {
      currentLevel = 1;
    }
    score = 0;  // Always reset score
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

    notifyListeners();
  }

  Future<void> _saveProgress() async {
    try {
      debugPrint('GameProvider: Saving progress - highest level: $highestUnlockedLevel');
      final prefs = await SharedPreferences.getInstance();
      if (highestUnlockedLevel > 0 && highestUnlockedLevel <= levelTargets.length) {
        await prefs.setInt('highest_unlocked_level', highestUnlockedLevel);
      }
    } catch (e) {
      debugPrint('GameProvider: Error saving progress: $e');
    }
  }

  void advanceLevel() {
    if (currentLevel < levelTargets.length) {
      // Update highest unlocked level if needed
      if (currentLevel >= highestUnlockedLevel) {
        highestUnlockedLevel = currentLevel + 1;
        _saveProgress(); // Save progress when unlocking new level
      }
      currentLevel++;
      debugPrint('GameProvider: Advanced to level $currentLevel, highest unlocked: $highestUnlockedLevel');
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
    
    // Special handling for bomb blocks
    if (block.isBomb) {
      clearSelection();
      selectedBlocks = [block];
      grid[row][col] = block.copyWith(isSelected: true);
      _audioService.playBurstSound();
      removeSelectedBlocks();
      return;
    }

    final List<Point<int>> matchingGroup = findMatchingGroup(row, col);
    
    if (matchingGroup.isEmpty) {
      clearSelection();
      return;
    }

    clearSelection();

    selectedBlocks = matchingGroup.map((point) {
      final block = grid[point.x][point.y]!;
      grid[point.x][point.y] = block.copyWith(isSelected: true);
      return block;
    }).toList();

    _audioService.playSelectSound();
    removeSelectedBlocks();
    
    notifyListeners();
  }

  void removeSelectedBlocks() {
    if (selectedBlocks.isEmpty) return;

    final bool isBombBlock = selectedBlocks.first.isBomb;
    final Color bombColor = selectedBlocks.first.color;
    
    if (isBombBlock) {
      // Remove all blocks of the same color
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          if (grid[row][col]?.color == bombColor) {
            grid[row][col] = null;
          }
        }
      }
      
      // Calculate score based on number of blocks removed
      int removedBlocks = selectedBlocks.length;
      int multiplier = 5; // Higher multiplier for bomb blocks
      int basePoints = 10;
      int levelBonus = currentLevel;
      score += removedBlocks * basePoints * multiplier * levelBonus;
    } else {
      // Normal block removal logic
      if (selectedBlocks.length < 3) return;

      // Remove selected blocks
      for (var block in selectedBlocks) {
        grid[block.row][block.col] = null;
      }

      // Update score - more blocks = higher multiplier
      int multiplier = selectedBlocks.length - 2;
      int basePoints = 10;
      int levelBonus = currentLevel;
      score += selectedBlocks.length * basePoints * multiplier * levelBonus;
    }

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
          grid[row][col] = createBlock(row, col);
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
    bool hasBombBlock = false;
    
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col]?.isBomb == true) {
          hasBombBlock = true;
          break;
        }
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
      if (hasBombBlock) break;
    }

    // If we have a bomb block, game is not over
    if (hasBombBlock) {
      isNearGameOver = false;
      isGameOver = false;
      return;
    }

    // If we get here and no bomb blocks found, no valid moves were found
    isGameOver = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}