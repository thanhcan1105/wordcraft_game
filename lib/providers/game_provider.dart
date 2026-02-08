import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../models/tile_state.dart';
import '../utils/adjacency_validator.dart';

/// Game state provider using ChangeNotifier for reactive UI updates
class GameProvider extends ChangeNotifier {
  // Game data
  late GameData _gameData;
  late List<List<LetterTile>> _grid;
  final List<FoundWord> _foundWords = [];
  WordSelection _currentSelection = WordSelection([]);
  bool _isInitialized = false;
  int _stateGeneration = 0; // Track game state version to cancel stale timers

  // Getters
  List<List<LetterTile>> get grid => _grid;
  List<FoundWord> get foundWords => _foundWords;
  WordSelection get currentSelection => _currentSelection;
  GameData get gameData => _gameData;
  bool get isInitialized => _isInitialized;

  /// Initialize game with data
  void initializeGame(GameData gameData) {
    _isInitialized = false;
    _stateGeneration++;

    _gameData = gameData;
    _grid =
        _createGridFromData(gameData.gridLetters, gameData.rows, gameData.cols);
    _foundWords.clear();
    _currentSelection = WordSelection([]);
    _isInitialized = true;
    notifyListeners();
  }

  /// Create grid of LetterTiles from letter data
  List<List<LetterTile>> _createGridFromData(
      List<List<String>> letters, int rows, int cols) {
    final grid = <List<LetterTile>>[];
    for (int row = 0; row < rows; row++) {
      final rowTiles = <LetterTile>[];
      for (int col = 0; col < cols; col++) {
        rowTiles.add(LetterTile(
          letter: letters[row][col],
          position: GridPosition(row, col),
        ));
      }
      grid.add(rowTiles);
    }
    return grid;
  }

  /// Start a new word selection
  void startSelection(GridPosition position) {
    if (!AdjacencyValidator.isValidPosition(
        position, _gameData.rows, _gameData.cols)) {
      return;
    }

    // Check if tile is already part of a found word
    if (_isPartOfFoundWord(position)) {
      return;
    }

    final tile = _grid[position.row][position.col];
    _currentSelection = WordSelection([tile]);
    _updateTileState(position, TileState.selected);
    notifyListeners();
  }

  /// Add a position to the current selection during swipe
  void addToSelection(GridPosition position) {
    if (!AdjacencyValidator.isValidPosition(
        position, _gameData.rows, _gameData.cols)) {
      return;
    }

    // Check if tile is already part of a found word
    if (_isPartOfFoundWord(position)) {
      return;
    }

    // Check if can add to selection (adjacency validation)
    if (!AdjacencyValidator.canAddToSelection(_currentSelection, position)) {
      return;
    }

    final tile = _grid[position.row][position.col];
    _currentSelection.tiles.add(tile);
    _updateTileState(position, TileState.selected);
    notifyListeners();
  }

  /// End the current selection and validate the word
  void endSelection() {
    if (_currentSelection.isEmpty) {
      return;
    }

    final selectedPositions =
        _currentSelection.tiles.map((t) => t.position).toList();

    // Check if these positions match any intended word solution
    String? foundWordKey;
    _gameData.wordPositions.forEach((word, positions) {
      if (_arePositionsEqual(selectedPositions, positions)) {
        // Check if this specific instance of the word is already found
        if (!_isPositionSetFound(positions)) {
          foundWordKey = word;
        }
      }
    });

    if (foundWordKey != null) {
      _handleCorrectWord(foundWordKey!, selectedPositions);
    } else {
      _handleIncorrectWord();
    }

    _currentSelection = WordSelection([]);
    notifyListeners();
  }

  bool _arePositionsEqual(List<GridPosition> list1, List<GridPosition> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  bool _isPositionSetFound(List<GridPosition> positions) {
    return _foundWords.any((fw) => _arePositionsEqual(fw.positions, positions));
  }

  /// Handle a correctly found word
  void _handleCorrectWord(String word, List<GridPosition> positions) {
    final category = _gameData.targetWords[word]!;
    final colorIndex = _gameData.categoryColors[category] ?? 0;

    // Create found word
    final foundWord = FoundWord(
      word: word,
      positions: positions,
      category: category,
      colorIndex: colorIndex,
    );

    _foundWords.add(foundWord);

    // Update tile states to correct
    for (final tile in _currentSelection.tiles) {
      _updateTileState(tile.position, TileState.correct);
    }
  }

  /// Handle an incorrect word selection
  void _handleIncorrectWord() {
    // Capture the current state and generation to validate the async callback
    final currentGen = _stateGeneration;
    final tilesToReset = List<LetterTile>.from(_currentSelection.tiles);

    // Set tiles to incorrect state
    for (final tile in tilesToReset) {
      _updateTileState(tile.position, TileState.incorrect);
    }

    // Reset to normal after a delay
    Future.delayed(const Duration(milliseconds: 600), () {
      // CRITICAL: Check if we are still in the same game generation
      if (!_isInitialized || _stateGeneration != currentGen) {
        return;
      }

      bool changed = false;
      for (final tile in tilesToReset) {
        final pos = tile.position;
        // Verify position is still valid for this specific generation's grid
        if (pos.row < _grid.length && pos.col < _grid[pos.row].length) {
          final currentTile = _grid[pos.row][pos.col];
          if (currentTile.state == TileState.incorrect &&
              !_isPartOfFoundWord(pos)) {
            _updateTileState(pos, TileState.normal);
            changed = true;
          }
        }
      }
      if (changed) {
        notifyListeners();
      }
    });
  }

  /// Check if a position is part of any found word
  bool _isPartOfFoundWord(GridPosition position) {
    return _foundWords.any((word) => word.positions.contains(position));
  }

  /// Update the state of a tile at a given position
  void _updateTileState(GridPosition position, TileState state) {
    _grid[position.row][position.col].state = state;
  }

  /// Get tile at position
  LetterTile getTileAt(GridPosition position) {
    return _grid[position.row][position.col];
  }

  /// Clear current selection (for cancel gestures)
  void clearSelection() {
    for (final tile in _currentSelection.tiles) {
      if (!_isPartOfFoundWord(tile.position)) {
        _updateTileState(tile.position, TileState.normal);
      }
    }
    _currentSelection = WordSelection([]);
    notifyListeners();
  }

  /// Reset the entire game
  void resetGame() {
    initializeGame(_gameData);
  }
}
