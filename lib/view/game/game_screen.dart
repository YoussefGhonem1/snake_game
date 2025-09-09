import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_game/view/game/game_board.dart';
import 'package:snake_game/view_model/game/game_view_model.dart';

class GameScreen extends StatefulWidget {
  final int? startLevelIndex;

  const GameScreen({super.key, this.startLevelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

int selectedSnakeIndex = 0;

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Hide system UI bars for immersive gaming experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadSelectedSnakeIndex().then((index) {
      setState(() {
        selectedSnakeIndex = index;
      });
    });
  }

  @override
  void dispose() {
    // Restore system UI bars when leaving the game
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // ** تعديل مهم: تحديث البيانات عند الخروج من شاشة اللعب **
    // هذا يضمن أن شاشة اختيار المستويات ستعرض أحدث تقدم
    Provider.of<GameViewModel>(context, listen: false).loadGameProgress();
    
    super.dispose();
  }

  Future<int> _loadSelectedSnakeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedSnakeIndex') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // ** تم حذف ChangeNotifierProvider من هنا **
    // الآن هذه الشاشة تستخدم نفس نسخة GameViewModel مع باقي التطبيق

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.05),
            child: Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: GameBoard(
                  height: height * 0.8, // Reduced for better centering
                  width: width * 0.95, // Slight margin on sides
                  startIndex: widget.startLevelIndex,
                  selectedSnakeIndex: selectedSnakeIndex,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}