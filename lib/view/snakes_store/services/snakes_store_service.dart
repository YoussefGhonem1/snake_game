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
    final userLevel = prefs.getInt(AppStrings.userLevel) ?? 10;
    final selectedSnakeIndex = prefs.getInt(AppStrings.selectedSnakeIndex) ?? 0;

    final ownedSnakes = List.generate(SnakeDesignsData.snakeDesigns.length, (
      index,
    ) {
      if (index == 0) return true;
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
    required int userLevel,
    required int selectedSnakeIndex,
    required List<bool> ownedSnakes,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(AppStrings.userCoins, userCoins);
    await prefs.setInt(AppStrings.userLevel, userLevel);
    await prefs.setInt(AppStrings.selectedSnakeIndex, selectedSnakeIndex);

    for (int i = 0; i < ownedSnakes.length; i++) {
      await prefs.setBool('${AppStrings.ownedSnakes}_$i', ownedSnakes[i]);
    }

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
