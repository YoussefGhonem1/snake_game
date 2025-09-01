import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_game/core/constants/strings.dart';
import 'package:snake_game/core/helpers/game_helper.dart';
import '../../../core/helpers/sound_helper.dart';
import '../../../model/snake_design.dart';
import '../data/snake_designs_data.dart';

class SnakesStoreService {
  static final SnakesStoreService _instance = SnakesStoreService._internal();
  factory SnakesStoreService() => _instance;
  SnakesStoreService._internal();

  Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final userCoins = prefs.getInt(AppStrings.userCoins) ?? 0;
    final userLevel = prefs.getInt(AppStrings.userLevel) ?? 1;
    final selectedSnakeIndex = prefs.getInt(AppStrings.selectedSnakeIndex) ?? 0;

    // Load owned snakes
    final ownedSnakes = List.generate(SnakeDesignsData.snakeDesigns.length, (
      index,
    ) {
      if (index == 0) return true; // Default snake is always owned
      return prefs.getBool('${AppStrings.ownedSnakes}_$index') ?? false;
    });

    return {
      'userCoins': userCoins,
      'userLevel': userLevel,
      'selectedSnakeIndex': selectedSnakeIndex,
      'ownedSnakes': ownedSnakes,
    };
  }

  Future<void> saveUserData({
    required int userCoins,
    required int selectedSnakeIndex,
    required List<bool> ownedSnakes,
  }) async {
    GameHelper.instance.updateUserCoins(userCoins);
    GameHelper.instance.updateSelectedSnakeIndex(selectedSnakeIndex);
    GameHelper.instance.updateOwnedSnakes(ownedSnakes);
  }

  bool canBuySnake(SnakeDesign snake, int userCoins, int userLevel) {
    return userCoins >= snake.price && userLevel >= snake.requiredLevel;
  }

  void playPurchaseSound() {
    SoundHelper.instance.playLevelCompleteSound();
  }

  void playSelectSound() {
    SoundHelper.instance.playEatSound();
  }

  List<SnakeDesign> getSnakeDesigns() {
    return SnakeDesignsData.snakeDesigns;
  }
}
