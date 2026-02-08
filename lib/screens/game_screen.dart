import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../widgets/game_background.dart';
import '../widgets/letter_grid.dart';
import '../widgets/found_words_section.dart';
import '../theme/app_theme.dart';

/// Main game screen
class GameScreen extends StatefulWidget {
  final GameData? gameData;

  const GameScreen({
    super.key,
    this.gameData,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize game with provided data or sample data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      gameProvider.initializeGame(widget.gameData ?? _generateNewGame());
    });
  }

  GameData _generateNewGame() {
    return GameData.generate(
      words: ['this', 'is', 'an', 'test', 'grid'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(AppTheme.spacingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wordcraft',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh,
                          color: Colors.white, size: 32),
                      onPressed: () {
                        context
                            .read<GameProvider>()
                            .initializeGame(_generateNewGame());
                      },
                    ),
                  ],
                ),
              ),

              // Letter Grid - Fixed size
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    child: const LetterGrid(),
                  ),
                ),
              ),

              SizedBox(height: AppTheme.spacingL),

              // Found Words Section - Scrollable
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusL),
                      topRight: Radius.circular(AppTheme.radiusL),
                    ),
                  ),
                  child: const SingleChildScrollView(
                    child: FoundWordsSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
