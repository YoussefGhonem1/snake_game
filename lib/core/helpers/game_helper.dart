import 'package:snake_game/core/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameHelper {
  GameHelper._();
  static GameHelper instance = GameHelper._();
  bool _isSwipe = true;
  final String _gameStartScore = "000000";

  late SharedPreferences _sharedPreferences;
  bool get isSwipe => _isSwipe;
  String get gameStartScore => _gameStartScore;

  initGameHelper() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _isSwipe = _sharedPreferences.getBool(AppStrings.isSwipeControl) ?? true;
  }

  void updateIsSwipe(bool isSwipe) {
    _isSwipe = isSwipe;
    _sharedPreferences.setBool(AppStrings.isSwipeControl, isSwipe);
  }

  void updateUserCoins(int coins) {
    _sharedPreferences.setInt(AppStrings.userCoins, coins);
  }

  void updateUserLevel(int level) {
    _sharedPreferences.setInt(AppStrings.userLevel, level);
  }

  void updateSelectedSnakeIndex(int index) {
    _sharedPreferences.setInt(AppStrings.selectedSnakeIndex, index);
  }

  void updateOwnedSnakes(List<bool> ownedSnakes) {
    for (int i = 0; i < ownedSnakes.length; i++) {
      _sharedPreferences.setBool(
        '${AppStrings.ownedSnakes}_$i',
        ownedSnakes[i],
      );
    }
  }
}
