import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
  }

  Future<void> _saveUserData() async {
    await _service.saveUserData(
      userCoins: userCoins,
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
          onPressed: () => navigateBack(context),
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
          // User Stats Header
          SliverToBoxAdapter(
            child: UserStatsHeader(userCoins: userCoins, userLevel: userLevel),
          ),

          // Snakes Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final snake = SnakeDesignsData.snakeDesigns[index];
                final isOwned = ownedSnakes[index];
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
