import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';
import '../models/level_config.dart';
import '../screens/level_complete_screen.dart';
import '../screens/level_screen.dart';
import '../data/level_data.dart';

class Block {
  final int row;
  final int col;
  final Color color;
  final bool isSelected;
  final BlockType type;
  final int iceLayer;
  final bool isPortal;
  final int? portalPairId;

  Block({
    required this.row,
    required this.col,
    required this.color,
    this.isSelected = false,
    this.type = BlockType.normal,
    this.iceLayer = 0,
    this.isPortal = false,
    this.portalPairId,
  });

  Block copyWith({
    int? row,
    int? col,
    Color? color,
    bool? isSelected,
    BlockType? type,
    int? iceLayer,
    bool? isPortal,
    int? portalPairId,
  }) {
    return Block(
      row: row ?? this.row,
      col: col ?? this.col,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
      type: type ?? this.type,
      iceLayer: iceLayer ?? this.iceLayer,
      isPortal: isPortal ?? this.isPortal,
      portalPairId: portalPairId ?? this.portalPairId,
    );
  }

  // Getters for block types
  bool get isBomb => type == BlockType.bomb;
  bool get isRocket => type == BlockType.rocket;
  bool get isRainbow => type == BlockType.rainbow;
  bool get isLocked => type == BlockType.locked;
  bool get hasIce => iceLayer > 0;
  bool get isStone => type == BlockType.stone;
}

class GameProvider extends ChangeNotifier {
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
  
  // Current level configuration
  late LevelConfig currentLevelConfig;
  
  // Objective tracking
  Map<LevelObjective, int> objectiveProgress = {};
  int movesLeft = 0;
  
  final Random _random = Random();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Add these properties near the top of the class
  int _totalCoins = 0;
  int get totalCoins => _totalCoins;
  bool isLevelComplete = false;

  GameProvider({required AudioService audioService}) : _audioService = audioService {
    _loadProgress();
  }

  Future<void> markTutorialAsSeen() async {
    if (!isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('should_show_tutorial', false);
      shouldShowTutorial = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving tutorial state: $e');
      // If there's an error saving the preference, just update the local state
      shouldShowTutorial = false;
      notifyListeners();
    }
  }

  void _initialize() async {
    // Load the first level configuration
    currentLevelConfig = LevelData.generateLevels()[0];
    
    // Initialize the game
    initializeGame();
    
    // Load saved progress
    try {
      final prefs = await SharedPreferences.getInstance();
      highestUnlockedLevel = prefs.getInt('highest_unlocked_level') ?? 1;
      shouldShowTutorial = prefs.getBool('should_show_tutorial') ?? true;
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
    
    isInitialized = true;
    notifyListeners();
  }

  Color _getRandomColor() {
    if (currentLevelConfig.availableColors.isEmpty) {
      return const Color(0xFF43CEA2);
    }
    return currentLevelConfig.availableColors[_random.nextInt(currentLevelConfig.availableColors.length)];
  }

  int getCurrentLevelTarget() {
    return currentLevelConfig.targetScore;
  }

  bool hasReachedLevelTarget() {
    // Check if all objectives are completed
    return hasCompletedAllObjectives();
  }

  // Add this method to update coins
  Future<void> addCoins(int amount) async {
    _totalCoins += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_coins', _totalCoins);
    notifyListeners();
  }

  // Update the startLevel method to load coins
  void startLevel(int level) {
    final levels = LevelData.generateLevels();
    if (level < 1 || level > levels.length) return;
    
    // Set the level configuration
    currentLevelConfig = levels[level - 1];
    currentLevel = level;
    
    // Reset objective progress
    objectiveProgress.clear();
    for (final objective in currentLevelConfig.objectives) {
      objectiveProgress[objective] = 0;
    }
    
    // Set moves limit
    movesLeft = currentLevelConfig.moveLimit;
    
    // Initialize the game with the new configuration
    initializeGame(false);
    
    notifyListeners();
  }

  Block createBlock(int row, int col) {
    final random = Random();
    final config = currentLevelConfig;
    
    // Check for initial layout
    if (config.initialLayout != null) {
      final blockType = config.initialLayout![row][col];
      if (blockType != BlockType.normal) {
        return Block(
          row: row,
          col: col,
          color: _getRandomColor(),
          type: blockType,
          isPortal: blockType == BlockType.portal,
          portalPairId: blockType == BlockType.portal ? _getPortalPairId(row, col) : null,
        );
      }
    }

    // Random block type generation based on probabilities
    BlockType type = BlockType.normal;
    int iceLayer = 0;
    bool isPortal = false;
    int? portalPairId;

    // Check probabilities in order of priority
    if (random.nextDouble() < config.stoneProbability) {
      type = BlockType.stone;
    } else if (random.nextDouble() < config.bombProbability) {
      type = BlockType.bomb;
    } else if (random.nextDouble() < config.rocketProbability) {
      type = BlockType.rocket;
    } else if (random.nextDouble() < config.rainbowProbability) {
      type = BlockType.rainbow;
    } else if (random.nextDouble() < config.iceProbability) {
      iceLayer = 2; // Two layers of ice
    }

    // Check if this position should be a portal
    final portalPosition = Point(row, col);
    if (config.portalPairs != null) {
      for (var pair in config.portalPairs!) {
        if (pair.contains(portalPosition)) {
          isPortal = true;
          portalPairId = config.portalPairs!.indexOf(pair);
          break;
        }
      }
    }

    return Block(
      row: row,
      col: col,
      color: _getRandomColor(),
      type: type,
      iceLayer: iceLayer,
      isPortal: isPortal,
      portalPairId: portalPairId,
    );
  }

  int _getPortalPairId(int row, int col) {
    if (currentLevelConfig.portalPairs == null) return -1;
    final position = Point(row, col);
    for (var i = 0; i < currentLevelConfig.portalPairs!.length; i++) {
      if (currentLevelConfig.portalPairs![i].contains(position)) {
        return i;
      }
    }
    return -1;
  }

  void initializeGame([bool isNewGame = true]) {
    // Clear any existing selections
    selectedBlocks = [];
    
    // Reset objective progress
    objectiveProgress.clear();
    for (final objective in currentLevelConfig.objectives) {
      objectiveProgress[objective] = 0;
    }
    
    // Reset moves
    movesLeft = currentLevelConfig.moveLimit;
    
    // Initialize the grid with the current level's dimensions
    grid = List.generate(currentLevelConfig.gridRows, (row) {
      return List.generate(currentLevelConfig.gridCols, (col) {
        // Check if this cell should be blocked
        if (currentLevelConfig.blockedCells?.contains(Point(row, col)) ?? false) {
          return null;
        }
        // Check if there's an initial layout
        if (currentLevelConfig.initialLayout != null) {
          final blockType = currentLevelConfig.initialLayout![row][col];
          if (blockType == BlockType.stone) {
            return null;
          }
          // Handle other block types here when implementing them
          return createBlock(row, col);
        }
        return createBlock(row, col);
      });
    });

    // Reset game state variables
    if (isNewGame) {
      currentLevel = 1;
      currentLevelConfig = LevelData.generateLevels()[0];
    }
    score = 0;
    updateObjectiveProgress(LevelObjective.score, 0);
    isGameOver = false;
    isNearGameOver = false;
    movesWithoutMatch = 0;

    // Check initial game state
    checkGameState();
    
    // If no valid moves are available, try again
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
      if (highestUnlockedLevel > 0 && highestUnlockedLevel <= LevelData.generateLevels().length) {
        await prefs.setInt('highest_unlocked_level', highestUnlockedLevel);
      }
    } catch (e) {
      debugPrint('GameProvider: Error saving progress: $e');
    }
  }

  void advanceLevel() {
    if (currentLevel < LevelData.generateLevels().length) {
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
      for (final Point<int> offset in [const Point(-1, 0), const Point(1, 0), const Point(0, -1), const Point(0, 1)]) {
        final int newRow = current.x + offset.x;
        final int newCol = current.y + offset.y;
        
        if (newRow >= 0 && newRow < currentLevelConfig.gridRows && 
            newCol >= 0 && newCol < currentLevelConfig.gridCols &&
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
    
    // Special handling for bomb blocks - they activate immediately on tap
    if (block.isBomb) {
      _handleBombBlock(block);
      return;
    }

    // Normal block matching logic
    final List<Point<int>> matchingGroup = findMatchingGroup(row, col);
    if (matchingGroup.isEmpty) {
      clearSelection();
      notifyListeners();
      return;
    }

    // Optimize selection by updating all blocks at once
    selectedBlocks = matchingGroup.map((point) {
      final block = grid[point.x][point.y]!;
      grid[point.x][point.y] = block.copyWith(isSelected: true);
      return block;
    }).toList();

    _audioService.playSelectSound();
    
    // Use Future.microtask to defer heavy operations
    Future.microtask(() {
      removeSelectedBlocks();
      notifyListeners();
    });
  }

  void removeSelectedBlocks() {
    if (selectedBlocks.isEmpty) return;

    final block = selectedBlocks.first;
    int removedBlocks = 0;
    int iceBlocksBroken = 0;
    
    // Play sound effect before heavy operations
    _audioService.playMatchSound();
    
    // Batch all grid updates
    List<Future<void>> updateOperations = [];
    
    if (block.isBomb) {
      // Bomb block logic - remove all blocks of the same color
      final bombColor = block.color;
      for (int row = 0; row < currentLevelConfig.gridRows; row++) {
        for (int col = 0; col < currentLevelConfig.gridCols; col++) {
          final currentBlock = grid[row][col];
          if (currentBlock != null && currentBlock.color == bombColor) {
            updateOperations.add(Future(() {
              if (currentBlock.hasIce) {
                final newIceLayer = currentBlock.iceLayer - 1;
                if (newIceLayer <= 0) {
                  grid[row][col] = null;
                  iceBlocksBroken++;
                } else {
                  grid[row][col] = currentBlock.copyWith(iceLayer: newIceLayer);
                }
              } else {
                grid[row][col] = null;
              }
              removedBlocks++;
            }));
          }
        }
      }
      
      // Update bomb objective
      incrementObjectiveProgress(LevelObjective.matchBombs);
    } else {
      // Normal block removal logic
      if (selectedBlocks.length < currentLevelConfig.minMatchSize) return;

      // Process portal blocks if any
      final portalBlocks = selectedBlocks.where((b) => b.isPortal).toList();
      if (portalBlocks.isNotEmpty) {
        for (final portalBlock in portalBlocks) {
          final connectedPortal = findConnectedPortal(portalBlock);
          if (connectedPortal != null) {
            addMatchingBlocksAroundPortal(connectedPortal);
          }
        }
      }

      // Remove selected blocks
      for (var block in selectedBlocks) {
        updateOperations.add(Future(() {
          if (block.hasIce) {
            final newIceLayer = block.iceLayer - 1;
            if (newIceLayer <= 0) {
              grid[block.row][block.col] = null;
              iceBlocksBroken++;
            } else {
              grid[block.row][block.col] = block.copyWith(iceLayer: newIceLayer);
            }
          } else {
            grid[block.row][block.col] = null;
          }
          removedBlocks++;
        }));
      }
    }

    // Execute all grid updates
    Future.wait(updateOperations).then((_) {
      // Update objectives
      incrementObjectiveProgress(LevelObjective.clearBlocks, removedBlocks);
      if (iceBlocksBroken > 0) {
        incrementObjectiveProgress(LevelObjective.breakIce, iceBlocksBroken);
      }

      // Calculate score
      int multiplier = selectedBlocks.length - (currentLevelConfig.minMatchSize - 1);
      int basePoints = 10;
      int levelBonus = currentLevel;
      int specialBlockBonus = block.isBomb || block.isRocket || block.isRainbow ? 2 : 1;
      score += basePoints * multiplier * levelBonus * specialBlockBonus;
      
      // Update score objective
      updateObjectiveProgress(LevelObjective.score, score);

      selectedBlocks.clear();
      movesWithoutMatch = 0;
      
      // Decrement moves left
      movesLeft--;
      
      // Apply gravity and fill empty spaces with slight delays
      Future.microtask(() {
        applyGravity();
        Future.delayed(const Duration(milliseconds: 50), () {
          fillEmptySpaces();
          Future.delayed(const Duration(milliseconds: 50), () {
            checkGameState();
            notifyListeners();
          });
        });
      });
    });
  }

  void _handleBombBlock(Block block) {
    clearSelection();
    grid[block.row][block.col] = block.copyWith(isSelected: true);
    selectedBlocks = [block];
    
    // Play sound effect before heavy operations
    _audioService.playBurstSound();
    
    // Batch all grid updates
    List<Future<void>> updateOperations = [];
    int removedBlocks = 0;
    int iceBlocksBroken = 0;
    
    final bombColor = block.color;
    
    for (int r = 0; r < currentLevelConfig.gridRows; r++) {
      for (int c = 0; c < currentLevelConfig.gridCols; c++) {
        final currentBlock = grid[r][c];
        if (currentBlock != null && currentBlock.color == bombColor) {
          updateOperations.add(Future(() {
            if (currentBlock.hasIce) {
              final newIceLayer = currentBlock.iceLayer - 1;
              if (newIceLayer <= 0) {
                grid[r][c] = null;
                iceBlocksBroken++;
              } else {
                grid[r][c] = currentBlock.copyWith(iceLayer: newIceLayer);
              }
            } else {
              grid[r][c] = null;
            }
            removedBlocks++;
          }));
        }
      }
    }
    
    // Execute all grid updates
    Future.wait(updateOperations).then((_) {
      // Update objectives and score
      incrementObjectiveProgress(LevelObjective.clearBlocks, removedBlocks);
      incrementObjectiveProgress(LevelObjective.matchBombs);
      if (iceBlocksBroken > 0) {
        incrementObjectiveProgress(LevelObjective.breakIce, iceBlocksBroken);
      }
      
      // Calculate score with bomb bonus
      score += removedBlocks * 20 * currentLevel * 2;
      updateObjectiveProgress(LevelObjective.score, score);
      
      // Clear selection and update game state
      selectedBlocks.clear();
      movesLeft--;
      movesWithoutMatch = 0;
      
      // Apply gravity and fill empty spaces with slight delays
      Future.microtask(() {
        applyGravity();
        Future.delayed(const Duration(milliseconds: 50), () {
          fillEmptySpaces();
          Future.delayed(const Duration(milliseconds: 50), () {
            checkGameState();
            notifyListeners();
          });
        });
      });
    });
  }

  void applyGravity() {
    for (int col = 0; col < currentLevelConfig.gridCols; col++) {
      int writePos = currentLevelConfig.gridRows - 1;
      
      // Skip blocked cells at the bottom
      while (writePos >= 0 && (currentLevelConfig.blockedCells?.contains(Point(writePos, col)) ?? false)) {
        writePos--;
      }
      
      for (int row = currentLevelConfig.gridRows - 1; row >= 0; row--) {
        // Skip blocked cells
        if (currentLevelConfig.blockedCells?.contains(Point(row, col)) ?? false) {
          continue;
        }
        
        if (grid[row][col] != null) {
          if (writePos != row) {
            grid[writePos][col] = grid[row][col]!.copyWith(row: writePos);
            grid[row][col] = null;
          }
          // Find next valid write position
          writePos--;
          while (writePos >= 0 && (currentLevelConfig.blockedCells?.contains(Point(writePos, col)) ?? false)) {
            writePos--;
          }
        }
      }
    }
    notifyListeners();
  }

  void fillEmptySpaces() {
    for (int col = 0; col < currentLevelConfig.gridCols; col++) {
      for (int row = currentLevelConfig.gridRows - 1; row >= 0; row--) {
        // Skip if this is a blocked cell
        if (currentLevelConfig.blockedCells?.contains(Point(row, col)) ?? false) {
          continue;
        }
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
    for (int i = col + 1; i < currentLevelConfig.gridCols && grid[row][i]?.color == color; i++) {
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
    for (int i = row + 1; i < currentLevelConfig.gridRows && grid[i][col]?.color == color; i++) {
      verticalCount++;
    }
    if (verticalCount >= 3) return true;

    return false;
  }

  // Enhanced game state checking
  void checkGameState() {
    // First check if level is complete
    if (hasCompletedAllObjectives() && !isLevelComplete) {
      completeLevel();
      return;
    }

    int possibleMoves = 0;
    bool hasBombBlock = false;
    
    for (int row = 0; row < currentLevelConfig.gridRows; row++) {
      for (int col = 0; col < currentLevelConfig.gridCols; col++) {
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

  // Get progress for a specific objective
  int getObjectiveProgress(LevelObjective objective) {
    return objectiveProgress[objective] ?? 0;
  }

  // Check if all objectives are completed
  bool hasCompletedAllObjectives() {
    if (currentLevelConfig.objectives.isEmpty) return false;
    
    for (final objective in currentLevelConfig.objectives) {
      final progress = getObjectiveProgress(objective);
      final target = currentLevelConfig.objectiveTargets[objective] ?? 0;
      
      if (progress < target) return false;
    }
    
    return true;
  }

  // Update progress for an objective
  void updateObjectiveProgress(LevelObjective objective, int value) {
    objectiveProgress[objective] = value;
    notifyListeners();
  }

  // Increment progress for an objective
  void incrementObjectiveProgress(LevelObjective objective, [int increment = 1]) {
    final currentProgress = getObjectiveProgress(objective);
    updateObjectiveProgress(objective, currentProgress + increment);
  }

  Block? findConnectedPortal(Block portalBlock) {
    if (!portalBlock.isPortal || portalBlock.portalPairId == null) return null;
    
    // Find the other portal with the same pair ID
    for (int row = 0; row < currentLevelConfig.gridRows; row++) {
      for (int col = 0; col < currentLevelConfig.gridCols; col++) {
        final block = grid[row][col];
        if (block != null && 
            block.isPortal && 
            block.portalPairId == portalBlock.portalPairId &&
            (block.row != portalBlock.row || block.col != portalBlock.col)) {
          return block;
        }
      }
    }
    return null;
  }

  void addMatchingBlocksAroundPortal(Block portalBlock) {
    final directions = [
      [-1, 0], // up
      [1, 0],  // down
      [0, -1], // left
      [0, 1],  // right
    ];

    final targetColor = selectedBlocks.first.color;

    for (final dir in directions) {
      final newRow = portalBlock.row + dir[0];
      final newCol = portalBlock.col + dir[1];

      if (newRow >= 0 && newRow < currentLevelConfig.gridRows &&
          newCol >= 0 && newCol < currentLevelConfig.gridCols) {
        final block = grid[newRow][newCol];
        if (block != null && 
            block.color == targetColor && 
            !selectedBlocks.contains(block)) {
          selectedBlocks.add(block);
          grid[newRow][newCol] = block.copyWith(isSelected: true);
        }
      }
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  // Add method to load progress including coins
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _totalCoins = prefs.getInt('total_coins') ?? 0;
    highestUnlockedLevel = prefs.getInt('highest_level') ?? 1;
    notifyListeners();
  }

  // Update completeLevel to handle coins asynchronously and show completion screen
  Future<void> completeLevel() async {
    isLevelComplete = true;
    
    // Award coins from level rewards
    if (currentLevelConfig.rewards.containsKey('coins')) {
      await addCoins(currentLevelConfig.rewards['coins']!);
    }
    
    // Update highest unlocked level if needed
    if (currentLevel >= highestUnlockedLevel) {
      highestUnlockedLevel = currentLevel + 1;
      _saveProgress();
    }
    
    // Show level complete screen
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => LevelCompleteScreen(
          score: score,
          level: currentLevel,
          objectiveProgress: objectiveProgress,
          levelConfig: currentLevelConfig,
          isLastLevel: currentLevel >= LevelData.generateLevels().length,
        ),
      ),
    );
    
    notifyListeners();
  }
}