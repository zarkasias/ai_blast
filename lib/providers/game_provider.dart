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
  bool isGameOver = false;
  bool isNearGameOver = false;
  List<Block> selectedBlocks = [];
  int movesWithoutMatch = 0;
  bool shouldShowTutorial = true;
  bool isInitialized = false;
  final AudioService _audioService = AudioService();
  
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

  GameProvider() {
    // Initialize grid immediately
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
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.wait([
        SharedPreferences.getInstance(),
        _audioService.initialize(),
      ]).then((results) {
        final prefs = results[0] as SharedPreferences;
        shouldShowTutorial = prefs.getBool('has_seen_tutorial') != true;
      });
      
      isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initialization: $e');
      // If there's an error, still mark as initialized
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

  void initializeGame() {
    selectedBlocks = [];
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
    score = 0;
    isGameOver = false;
    isNearGameOver = false;
    movesWithoutMatch = 0;
    notifyListeners();
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

  void selectBlock(int row, int col) {
    if (grid[row][col] == null) return;
    
    final block = grid[row][col]!;
    
    // If clicking an already selected block, remove blocks
    if (block.isSelected) {
      if (selectedBlocks.length >= 2) {
        removeSelectedBlocks();
      } else {
        clearSelection();
      }
      return;
    }

    // If clicking a new block with different color, clear selection
    if (selectedBlocks.isNotEmpty && selectedBlocks[0].color != block.color) {
      clearSelection();
    }

    // Check if the new block is adjacent to any selected block
    if (selectedBlocks.isNotEmpty && 
        !selectedBlocks.any((selected) => areBlocksAdjacent(selected, block))) {
      clearSelection();
    }

    // Add the block to selection
    selectedBlocks.add(block);
    grid[row][col] = block.copyWith(isSelected: true);
    _audioService.playSelectSound();
    
    notifyListeners();
  }

  void removeSelectedBlocks() {
    if (selectedBlocks.length < 2) return;

    // Remove selected blocks and update score
    for (var block in selectedBlocks) {
      grid[block.row][block.col] = null;
    }

    // Update score - more blocks = higher multiplier
    int multiplier = selectedBlocks.length - 1;
    score += selectedBlocks.length * 10 * multiplier;

    _audioService.playMatchSound();
    selectedBlocks.clear();
    movesWithoutMatch = 0;

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
    
    // Check horizontally
    if (col > 0 && grid[row][col - 1]?.color == color) return true;
    if (col < gridSize - 1 && grid[row][col + 1]?.color == color) return true;
    
    // Check vertically
    if (row > 0 && grid[row - 1][col]?.color == color) return true;
    if (row < gridSize - 1 && grid[row + 1][col]?.color == color) return true;
    
    return false;
  }

  // Enhanced game state checking
  void checkGameState() {
    int possibleMoves = 0;
    
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (hasMatchingNeighbors(row, col)) {
          possibleMoves++;
        }
      }
    }

    // Set warning state if few moves are left
    isNearGameOver = possibleMoves < 5;
    
    // Game is over if no moves are possible
    if (possibleMoves == 0) {
      isGameOver = true;
      // Save high score or trigger other end-game events here
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}