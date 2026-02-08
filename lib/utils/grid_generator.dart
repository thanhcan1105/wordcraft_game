import 'dart:math';
import '../models/game_models.dart';

/// Result of the grid generation process
class GridResult {
  final List<List<String>> grid;
  final Map<String, List<GridPosition>> solutions;

  GridResult(this.grid, this.solutions);
}

/// Utility to generate a letter grid from a list of words
class GridGenerator {
  final Random _random = Random();

  /// Generates a grid of [rows] x [cols] containing the given [words].
  /// Returns a [GridResult] containing the grid and the solution paths.
  GridResult? generateGrid({
    required List<String> words,
    required int rows,
    required int cols,
  }) {
    List<List<String?>> grid = List.generate(
      rows,
      (_) => List<String?>.filled(cols, null),
    );
    Map<String, List<GridPosition>> solutions = {};

    if (_backtrack(grid, solutions, words, 0, rows, cols)) {
      // Fill remaining nulls with random letters
      final finalGrid = grid.map((row) {
        return row
            .map((char) => char ?? _randomLetter())
            .toList()
            .cast<String>();
      }).toList();

      return GridResult(finalGrid, solutions);
    }

    return null;
  }

  bool _backtrack(
    List<List<String?>> grid,
    Map<String, List<GridPosition>> solutions,
    List<String> words,
    int wordIndex,
    int rows,
    int cols,
  ) {
    if (wordIndex == words.length) {
      return true;
    }

    String word = words[wordIndex].toUpperCase();

    // Try all starting positions
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == null) {
          final path = <GridPosition>[];
          if (_placeWord(grid, solutions, word, 0, r, c, rows, cols, words,
              wordIndex, path)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _placeWord(
    List<List<String?>> grid,
    Map<String, List<GridPosition>> solutions,
    String word,
    int charIndex,
    int r,
    int c,
    int rows,
    int cols,
    List<String> words,
    int wordIndex,
    List<GridPosition> currentPath,
  ) {
    if (r < 0 || r >= rows || c < 0 || c >= cols || grid[r][c] != null) {
      return false;
    }

    // Place character
    grid[r][c] = word[charIndex];
    currentPath.add(GridPosition(r, c));

    if (charIndex == word.length - 1) {
      // Word finished, move to next word
      solutions[word] = List.from(currentPath);
      if (_backtrack(grid, solutions, words, wordIndex + 1, rows, cols)) {
        return true;
      }
      // If next word fails, clean up solution entry
      solutions.remove(word);
    } else {
      // Try next characters in 4 directions
      final directions = [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0]
      ]..shuffle(_random);
      for (var dir in directions) {
        if (_placeWord(grid, solutions, word, charIndex + 1, r + dir[0],
            c + dir[1], rows, cols, words, wordIndex, currentPath)) {
          return true;
        }
      }
    }

    // Backtrack
    grid[r][c] = null;
    currentPath.removeLast();
    return false;
  }

  String _randomLetter() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return letters[_random.nextInt(letters.length)];
  }
}
