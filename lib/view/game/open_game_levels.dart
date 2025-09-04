import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/game_colors.dart';
import 'package:snake_game/core/helpers/navigate_helper.dart';
import 'package:snake_game/view_model/game/free_mode_game_view_model.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_manager.dart';
import '../../model/model/level.dart';
import '../../view_model/game/game_view_model.dart';
import '../../view/game/free_mode_game_screen.dart';

class OpenGameLevels extends StatefulWidget {
  const OpenGameLevels({super.key});
  @override
  State<OpenGameLevels> createState() => _OpenGameLevelsState();
}

class _OpenGameLevelsState extends State<OpenGameLevels> {
  ColorHelper colorHelper = ColorHelper.instance;
  late GameViewModel gameScreenViewModel;
  List<GameLevel> _gameLevels = [];
  bool _isFreeMode = false; // Default to level mode

  @override
  void initState() {
    super.initState();
    gameScreenViewModel = Provider.of<GameViewModel>(context, listen: false);
    gameScreenViewModel.loadGameProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Arguments are only available after initState, so we parse them here.
    // This method is called right after initState.
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final gameMode = args?['gameMode'] ?? 'level';
    _isFreeMode = gameMode == 'free';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0A),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern header with back button and title
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colorHelper.secondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorHelper.primary.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: colorHelper.primary,
                        ),
                        onPressed: () {
                          navigateBack(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        _isFreeMode
                            ? context.tr('free_mode')
                            : context.tr('level_mode'),
                        style: TextStyle(
                          color: colorHelper.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Modern grid with improved spacing
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  itemCount: gameScreenViewModel.maxLevels,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    return getLevelWidget(context, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getLevelWidget(BuildContext context, int index) {
    // Use the new enhanced score system for level unlocking
    bool isLevelUnlocked = index < gameScreenViewModel.maxUnlockedLevel;
    //bool isLevelUnlocked =true;

    // In free mode, show all unlocked levels; in level mode, use traditional progression
    if (!isLevelUnlocked && (_isFreeMode || index > 0)) {
      return InkWell(
        onTap: () {
          lockedLevelMessage(context, index);
        },
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorHelper.secondary.withOpacity(0.6),
                    colorHelper.secondary.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorHelper.secondary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: colorHelper.secondary.withOpacity(0.7),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorHelper.secondary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock,
                  color: colorHelper.secondary.withOpacity(0.9),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () async {
        print("Selected level: ${index + 1}, Free Mode: $_isFreeMode");

        if (_isFreeMode) {
          // Navigate directly to the new FreeModeGameScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FreeModeGameScreen(startLevelIndex: index),
            ),
          );
        } else {
          // Set the game mode for level mode
          gameScreenViewModel.setGameMode(
            GameMode.levelMode,
            selectedLevel: index,
          );

          // Navigate directly to the enhanced game screen (ads removed)
          navigateTo(
            context,
            RoutePath.gameScreen,
            arguments: {"index": index},
          );
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorHelper.primary.withOpacity(0.8),
              colorHelper.primary.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorHelper.primary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorHelper.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isFreeMode
            ? FutureBuilder<int>(
                future: FreeModeGameViewModel.getStaticLevelHighScore(index),
                builder: (context, snapshot) {
                  int highScore = snapshot.data ?? 0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${index + 1}",
                        style: TextStyle(
                          color: colorHelper.appOnButtonSecondColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (highScore > 0) ...[
                        SizedBox(height: 4),
                        Text(
                          "${context.tr('best')}: $highScore",
                          style: TextStyle(
                            color: colorHelper.appOnButtonSecondColor
                                .withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        SizedBox(height: 4),
                        Text(
                          "${context.tr('best')}: 0",
                          style: TextStyle(
                            color: colorHelper.appOnButtonSecondColor
                                .withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              )
            : Text(
                "${index + 1}",
                style: TextStyle(
                  color: colorHelper.appOnButtonSecondColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  getOpenGameLevels() {
    _gameLevels = [
      GameLevel(
        levelNumber: 1,
        levelBarriers: [gameScreenViewModel.getBarriersLevelOne()],
        maxScore: 25000,
        snake: List.generate(4, (index) => Offset(5, (13 - index).toDouble())),
      ),
      GameLevel(
        levelNumber: 2,
        levelBarriers: [gameScreenViewModel.getBarriersLevelTwo()],
        maxScore: 30000,
        snake: List.generate(4, (index) => Offset(5, (13 - index).toDouble())),
      ),
      GameLevel(
        levelNumber: 3,
        levelBarriers: [gameScreenViewModel.getBarriersLevelThree()],
        maxScore: 35000,
        snake: List.generate(4, (index) => Offset(2, (6 - index).toDouble())),
      ),
      GameLevel(
        levelNumber: 4,
        levelBarriers: [gameScreenViewModel.getBarriersLevelFour()],
        maxScore: 40000,
        snake: List.generate(4, (index) => Offset(5, (13 - index).toDouble())),
      ),
      GameLevel(
        levelNumber: 5,
        levelBarriers: [gameScreenViewModel.getBarriersLevelFive()],
        maxScore: 45000,
        snake: List.generate(4, (index) => Offset(5, (13 - index).toDouble())),
      ),
    ];

    return _gameLevels;
  }

  lockedLevelMessage(BuildContext gameContext, int index) async {
    showDialog(
      barrierDismissible: false,
      context: gameContext,
      builder: (_) => Container(
        color: colorHelper.appBackgroundColor,
        child: AlertDialog(
          backgroundColor: colorHelper.alertDialogBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'your_score'.tr(args: [gameScreenViewModel.score]),
                style: TextStyle(color: colorHelper.alertTextColor),
              ),
              Text(
                'level_locked_at_least'.tr(
                  args: [_gameLevels[index].maxScore.toString()],
                ),
                style: TextStyle(color: colorHelper.alertTextColor),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(gameContext).pop();
              },
              child: Text(
                'ok'.tr(),
                style: TextStyle(color: colorHelper.alertTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
