import 'tile_state.dart';
import '../utils/grid_generator.dart';

/// Represents a position in the grid
class GridPosition {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPosition($row, $col)';
}

/// Represents a single letter tile in the grid
class LetterTile {
  final String letter;
  final GridPosition position;
  TileState state;

  LetterTile({
    required this.letter,
    required this.position,
    this.state = TileState.normal,
  });

  /// Create a copy of this tile with updated state
  LetterTile copyWith({
    String? letter,
    GridPosition? position,
    TileState? state,
  }) {
    return LetterTile(
      letter: letter ?? this.letter,
      position: position ?? this.position,
      state: state ?? this.state,
    );
  }
}

/// Represents the current word selection during a swipe
class WordSelection {
  final List<LetterTile> tiles;

  WordSelection(this.tiles);

  String get word => tiles.map((t) => t.letter).join();

  bool get isEmpty => tiles.isEmpty;

  int get length => tiles.length;

  /// Check if a position is already in the selection
  bool containsPosition(GridPosition position) {
    return tiles.any((tile) => tile.position == position);
  }

  /// Get the last selected position
  GridPosition? get lastPosition {
    return tiles.isEmpty ? null : tiles.last.position;
  }
}

/// Represents a word that has been found
class FoundWord {
  final String word;
  final List<GridPosition> positions;
  final String category;
  final int colorIndex; // For different color highlights

  FoundWord({
    required this.word,
    required this.positions,
    required this.category,
    required this.colorIndex,
  });
}

/// Flexible data model for game configuration
/// This allows easy data injection for different levels/games
class GameData {
  /// Grid dimensions
  final int rows;
  final int cols;

  /// Grid of letters
  final List<List<String>> gridLetters;

  /// Target words to find (word -> category)
  final Map<String, String> targetWords;

  /// Exact tile positions for each word (word -> list of positions)
  final Map<String, List<GridPosition>> wordPositions;

  /// Categories and their display colors
  final Map<String, int> categoryColors;

  GameData({
    required this.rows,
    required this.cols,
    required this.gridLetters,
    required this.targetWords,
    required this.wordPositions,
    required this.categoryColors,
  });

  /// Generate a game automatically from a list of words
  factory GameData.generate({
    required List<String> words,
    int? rows,
    int? cols,
    Map<String, String>? categories,
  }) {
    // If rows or cols are not provided, calculate optimal dimensions based on total character count
    int finalRows = rows ?? 0;
    int finalCols = cols ?? 0;

    if (finalRows == 0 || finalCols == 0) {
      int totalChars = words.fold(0, (sum, word) => sum + word.length);

      // Better logic for dynamic dimensions
      if (totalChars <= 4) {
        finalRows = 2;
        finalCols = 2;
      } else if (totalChars <= 6) {
        finalRows = 2;
        finalCols = 3;
      } else if (totalChars <= 9) {
        finalRows = 3;
        finalCols = 3;
      } else if (totalChars <= 12) {
        finalRows = 3;
        finalCols = 4;
      } else if (totalChars <= 16) {
        finalRows = 4;
        finalCols = 4;
      } else if (totalChars <= 20) {
        finalRows = 4;
        finalCols = 5;
      } else {
        finalRows = 5;
        finalCols = 5;
      }
    }

    final generator = GridGenerator();
    final result =
        generator.generateGrid(words: words, rows: finalRows, cols: finalCols);

    if (result == null) {
      throw Exception('Could not generate a valid grid for these words');
    }

    // If no specific categories provided, treat each word as its own category for unique colors
    final finalCategories = categories ?? {for (var w in words) w: w};

    // Default colors for categories
    final distinctCategories = finalCategories.values.toSet().toList();
    final colMap = {
      for (int i = 0; i < distinctCategories.length; i++)
        distinctCategories[i]: i
    };

    return GameData(
      rows: finalRows,
      cols: finalCols,
      gridLetters: result.grid,
      targetWords: {for (var w in words) w.toUpperCase(): finalCategories[w]!},
      wordPositions: result.solutions,
      categoryColors: colMap,
    );
  }

  /// Create sample game data for testing
  factory GameData.sample() {
    return GameData(
      rows: 4,
      cols: 5,
      gridLetters: [
        ['B', 'E', 'D', 'S', 'A'],
        ['D', 'N', 'A', 'H', 'D'],
        ['Q', 'U', 'E', 'S', 'T'],
        ['G', 'O', 'N', 'O', 'I'],
      ],
      targetWords: {
        'BED': 'Giường',
        'HAND': 'Tay',
        'SAD': 'Buồn',
        'QUESTION': 'Câu hỏi',
        'GO': 'Đi',
      },
      wordPositions: {
        'BED': [GridPosition(0, 0), GridPosition(0, 1), GridPosition(0, 2)],
        'SAD': [GridPosition(0, 3), GridPosition(0, 4), GridPosition(1, 4)],
        'HAND': [
          GridPosition(1, 3),
          GridPosition(1, 2),
          GridPosition(1, 1),
          GridPosition(1, 0)
        ],
        'QUESTION': [
          GridPosition(2, 0),
          GridPosition(2, 1),
          GridPosition(2, 2),
          GridPosition(2, 3),
          GridPosition(2, 4),
          GridPosition(3, 4),
          GridPosition(3, 3),
          GridPosition(3, 2)
        ],
        'GO': [GridPosition(3, 0), GridPosition(3, 1)],
      },
      categoryColors: {
        'Giường': 0,
        'Tay': 1,
        'Buồn': 3,
        'Câu hỏi': 2,
        'Đi': 4,
      },
    );
  }
}
