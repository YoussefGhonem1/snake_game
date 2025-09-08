import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_game/view/game/free_mode_game_board.dart';
import 'package:snake_game/view_model/game/free_mode_game_view_model.dart';
import 'package:provider/provider.dart';

class FreeModeGameScreen extends StatefulWidget {
  final int? startLevelIndex;

  const FreeModeGameScreen({super.key, this.startLevelIndex});

  @override
  State<FreeModeGameScreen> createState() => _FreeModeGameScreenState();
}

int selectedSnakeIndex = 0;

class _FreeModeGameScreenState extends State<FreeModeGameScreen> {
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

    return ChangeNotifierProvider(
      create: (context) => FreeModeGameViewModel(),
      child: Consumer<FreeModeGameViewModel>(
        builder: (context, provider, _) {
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
                      child: FreeModeGameBoard(
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
        },
      ),
    );
  }
}
