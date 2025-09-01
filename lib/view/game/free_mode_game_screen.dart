import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/view/game/free_mode_game_board.dart';
import 'package:snake_game/view_model/game/free_mode_game_view_model.dart';
import 'package:provider/provider.dart';

class FreeModeGameScreen extends StatefulWidget {
  final int? startLevelIndex;

  const FreeModeGameScreen({super.key, this.startLevelIndex});

  @override
  State<FreeModeGameScreen> createState() => _FreeModeGameScreenState();
}

class _FreeModeGameScreenState extends State<FreeModeGameScreen> {
  @override
  void initState() {
    super.initState();
    // Hide system UI bars for immersive gaming experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI bars when leaving the game
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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
                        height: height * 0.65, // Reduced for better centering
                        width: width * 0.95, // Slight margin on sides
                        startIndex: widget.startLevelIndex,
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
