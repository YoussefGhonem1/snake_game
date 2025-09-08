import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/game_colors.dart';
import '../../core/helpers/navigate_helper.dart';
import '../../model/snake_design.dart';
import 'data/snake_designs_data.dart';
import 'services/snakes_store_service.dart';
import 'widgets/insufficient_resources_dialog.dart';
import 'widgets/purchase_success_dialog.dart';
import 'widgets/snake_card.dart';
import 'widgets/user_stats_header.dart';

class SnakesStoreScreen extends StatefulWidget {
  const SnakesStoreScreen({super.key});

  @override
  State<SnakesStoreScreen> createState() => _SnakesStoreScreenState();
}

class _SnakesStoreScreenState extends State<SnakesStoreScreen>
    with TickerProviderStateMixin {
  int userCoins = 0;
  int userLevel = 1;
  int selectedSnakeIndex = 0;
  List<bool> ownedSnakes = [];
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final SnakesStoreService _service = SnakesStoreService();

  @override
  void initState() {
    super.initState();
    _initializeGlowAnimation();
    _loadUserData();
  }

  void _initializeGlowAnimation() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  Future<void> _loadUserData() async {
    final userData = await _service.loadUserData();
    setState(() {
      userCoins = userData['userCoins'];
      userLevel = userData['userLevel'];
      selectedSnakeIndex = userData['selectedSnakeIndex'];
      ownedSnakes = userData['ownedSnakes'];
    });

    debugPrint("Owned snakes: $ownedSnakes");
  }

  int levelIndex = 0;
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('levelHighScore_$levelIndex', userCoins);
    await _service.saveUserData(
      userCoins: userCoins,
      userLevel: userLevel,
      selectedSnakeIndex: selectedSnakeIndex,
      ownedSnakes: ownedSnakes,
    );
  }

  void _buySnake(int index) {
    final snake = SnakeDesignsData.snakeDesigns[index];
    if (_service.canBuySnake(snake, userCoins, userLevel)) {
      setState(() {
        userCoins -= snake.price;
        ownedSnakes[index] = true;
        selectedSnakeIndex = index;
      });
      _saveUserData();
      _service.playPurchaseSound();
      _showPurchaseSuccessDialog(snake.name);
    } else {
      _showInsufficientResourcesDialog(snake);
    }
  }

  void _selectSnake(int index) {
    if (ownedSnakes[index]) {
      setState(() {
        selectedSnakeIndex = index;
      });
      _saveUserData();
      _service.playSelectSound();
    }
  }

  void _showPurchaseSuccessDialog(String snakeName) {
    showDialog(
      context: context,
      builder: (context) => PurchaseSuccessDialog(snakeName: snakeName),
    );
  }

  void _showInsufficientResourcesDialog(SnakeDesign snake) {
    showDialog(
      context: context,
      builder: (context) => InsufficientResourcesDialog(
        snake: snake,
        userCoins: userCoins,
        userLevel: userLevel,
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorHelper.instance.gameBackgroundColor,
      appBar: AppBar(
        backgroundColor: ColorHelper.instance.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorHelper.instance.onSecondary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          context.tr('snake_store'),
          style: TextStyle(
            color: ColorHelper.instance.onSecondary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: UserStatsHeader(userCoins: userCoins, userLevel: userLevel),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final snake = SnakeDesignsData.snakeDesigns[index];
                final isOwned = ownedSnakes.isNotEmpty && ownedSnakes[index];
                final isSelected = selectedSnakeIndex == index;
                final canBuy = _service.canBuySnake(
                  snake,
                  userCoins,
                  userLevel,
                );
                final isLocked = !isOwned && !canBuy;

                return SnakeCard(
                  snake: snake,
                  index: index,
                  isOwned: isOwned,
                  isSelected: isSelected,
                  canBuy: canBuy,
                  isLocked: isLocked,
                  glowAnimation: _glowAnimation,
                  onTap: () {
                    if (isOwned) {
                      _selectSnake(index);
                    } else if (canBuy) {
                      _buySnake(index);
                    }
                  },
                );
              }, childCount: SnakeDesignsData.snakeDesigns.length),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import '../../core/constants/game_colors.dart';
// import '../../core/helpers/navigate_helper.dart';
// import '../../model/snake_design.dart';
// import 'data/snake_designs_data.dart';
// import 'services/snakes_store_service.dart';
// import 'widgets/insufficient_resources_dialog.dart';
// import 'widgets/purchase_success_dialog.dart';
// import 'widgets/snake_card.dart';
// import 'widgets/user_stats_header.dart';

// enum PurchaseMode { level, points }

// class SnakesStoreScreen extends StatefulWidget {
//   const SnakesStoreScreen({super.key});

//   @override
//   State<SnakesStoreScreen> createState() => _SnakesStoreScreenState();
// }

// class _SnakesStoreScreenState extends State<SnakesStoreScreen>
//     with TickerProviderStateMixin {
//   int userCoins = 0;
//   int userLevel = 1;
//   int selectedSnakeIndex = 0;
//   List<bool> ownedSnakes = [];
//   late AnimationController _glowController;
//   late Animation<double> _glowAnimation;

//   final SnakesStoreService _service = SnakesStoreService();

//   PurchaseMode? _purchaseMode;

//   @override
//   void initState() {
//     super.initState();
//     _initializeGlowAnimation();
//     _loadUserData().then((_) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showPurchaseModeDialog();
//       });
//     });
//   }

//   void _initializeGlowAnimation() {
//     _glowController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
//     );
//     _glowController.repeat(reverse: true);
//   }

//   Future<void> _loadUserData() async {
//     final userData = await _service.loadUserData();
//     setState(() {
//       userCoins = userData['userCoins'];
//       userLevel = userData['userLevel'];
//       selectedSnakeIndex = userData['selectedSnakeIndex'];
//       ownedSnakes = userData['ownedSnakes'];
//     });

//     debugPrint("Owned snakes: $ownedSnakes");
//   }

//   Future<void> _saveUserData() async {
//     await _service.saveUserData(
//       userCoins: userCoins,
//       userLevel: userLevel,
//       selectedSnakeIndex: selectedSnakeIndex,
//       ownedSnakes: ownedSnakes,
//     );
//   }

//   void _buySnake(int index) {
//     final snake = SnakeDesignsData.snakeDesigns[index];

//     bool canBuy = false;
//     if (_purchaseMode == PurchaseMode.points) {
//       canBuy = userCoins >= snake.price;
//     } else if (_purchaseMode == PurchaseMode.level) {
//       canBuy = userLevel >= snake.requiredLevel;
//     }

//     if (canBuy) {
//       setState(() {
//         if (_purchaseMode == PurchaseMode.points) {
//           userCoins -= snake.price;
//         }
//         ownedSnakes[index] = true;
//         selectedSnakeIndex = index;
//       });
//       _saveUserData();
//       _service.playPurchaseSound();
//       _showPurchaseSuccessDialog(snake.name);
//     } else {
//       _showInsufficientResourcesDialog(snake);
//     }
//   }

//   void _selectSnake(int index) {
//     if (ownedSnakes[index]) {
//       setState(() {
//         selectedSnakeIndex = index;
//       });
//       _saveUserData();
//       _service.playSelectSound();
//     }
//   }

//   void _showPurchaseSuccessDialog(String snakeName) {
//     showDialog(
//       context: context,
//       builder: (context) => PurchaseSuccessDialog(snakeName: snakeName),
//     );
//   }

//   void _showInsufficientResourcesDialog(SnakeDesign snake) {
//     showDialog(
//       context: context,
//       builder: (context) => InsufficientResourcesDialog(
//         snake: snake,
//         userCoins: userCoins,
//         userLevel: userLevel,
//       ),
//     );
//   }

//   void _showPurchaseModeDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: true, // close when tapping outside
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: const Color(0xFF1C1C1E), // dark card bg
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Choose Purchase Mode",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 "Unlock snakes using coins or by reaching levels.",
//                 style: TextStyle(fontSize: 14, color: Colors.white70),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),

//               // Buttons row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Coins button
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       setState(() => _purchaseMode = PurchaseMode.points);
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(
//                       Icons.monetization_on,
//                       color: Colors.yellow,
//                     ),
//                     label: const Text(
//                       "Coins",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2C2C2E), // dark button
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),

//                   // Level button
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       setState(() => _purchaseMode = PurchaseMode.level);
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.star, color: Colors.blueAccent),
//                     label: const Text(
//                       "Level",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2C2C2E),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _glowController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorHelper.instance.gameBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: ColorHelper.instance.secondary,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: ColorHelper.instance.onSecondary),
//           onPressed: () => navigateBack(context),
//         ),
//         title: Text(
//           context.tr('snake_store'),
//           style: TextStyle(
//             color: ColorHelper.instance.onSecondary,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: UserStatsHeader(userCoins: userCoins, userLevel: userLevel),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.all(16),
//             sliver: SliverGrid(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 0.8,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//               ),
//               delegate: SliverChildBuilderDelegate((context, index) {
//                 final snake = SnakeDesignsData.snakeDesigns[index];
//                 final isOwned = ownedSnakes.isNotEmpty && ownedSnakes[index];
//                 final isSelected = selectedSnakeIndex == index;

//                 bool canBuy = false;
//                 if (_purchaseMode == PurchaseMode.points) {
//                   canBuy = userCoins >= snake.price;
//                 } else if (_purchaseMode == PurchaseMode.level) {
//                   canBuy = userLevel >= snake.requiredLevel;
//                 }

//                 final isLocked = !isOwned && !canBuy;

//                 return SnakeCard(
//                   snake: snake,
//                   index: index,
//                   isOwned: isOwned,
//                   isSelected: isSelected,
//                   canBuy: canBuy,
//                   isLocked: isLocked,
//                   glowAnimation: _glowAnimation,
//                   purchaseMode: _purchaseMode,
//                   onTap: () {
//                     if (isOwned) {
//                       _selectSnake(index);
//                     } else if (canBuy) {
//                       _buySnake(index);
//                     }
//                   },
//                 );
//               }, childCount: SnakeDesignsData.snakeDesigns.length),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
