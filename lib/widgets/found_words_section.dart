import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// Display section for found words, organized by category
class FoundWordsSection extends StatelessWidget {
  const FoundWordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (!gameProvider.isInitialized) {
          return const SizedBox.shrink();
        }
        // Group found words by category
        final wordsByCategory = <String, List<FoundWord>>{};
        for (final word in gameProvider.foundWords) {
          wordsByCategory.putIfAbsent(word.category, () => []).add(word);
        }

        // Get all categories from game data
        final allCategories =
            gameProvider.gameData.categoryColors.keys.toList();

        return Container(
          padding: EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display each category
              ...allCategories.map((category) {
                final wordsInCategory = wordsByCategory[category] ?? [];
                return _buildCategorySection(
                  category: category,
                  words: wordsInCategory,
                  colorIndex:
                      gameProvider.gameData.categoryColors[category] ?? 0,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Build a section for a single category
  Widget _buildCategorySection({
    required String category,
    required List<FoundWord> words,
    required int colorIndex,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category label
          Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppTheme.spacingS),

          // Words in this category
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingS,
            children: words.map((word) {
              return _buildWordChip(word.word, colorIndex);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build a chip for a found word
  Widget _buildWordChip(String word, int colorIndex) {
    final color =
        AppColors.categoryColors[colorIndex % AppColors.categoryColors.length];

    return AnimatedContainer(
      duration: AppTheme.mediumAnimation,
      curve: AppTheme.bounceCurve,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppTheme.elevationMedium,
            offset: Offset(0, AppTheme.elevationMedium / 2),
          ),
        ],
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
