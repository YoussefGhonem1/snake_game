# 🐍 Powerful Snake Game

A feature-rich, modern Snake game built with Flutter featuring advanced gameplay mechanics, stunning visual themes, and comprehensive game statistics.

## ✨ Powerful Features

### 🎮 Advanced Gameplay
- **4 Difficulty Levels**: Easy, Medium, Hard, Insane
- **Progressive Speed**: Game speed increases with each level
- **Multiple Lives**: Start with 3 lives, lose one on collision
- **Level System**: Advance levels every 100 points
- **Pause/Resume**: Pause the game anytime during play

### 🎯 Special Food Types
- **Normal Food** (Red Apple): 10 points
- **Golden Food** (Star): 50 points + bonus
- **Rainbow Food** (Magic): 30 points + grows snake by 2 segments
- **Toxic Food** (Dangerous): -20 points + shrinks snake (unless invincible)

### ⚡ Power-Up System
- **Speed Boost** (⚡): Increases snake speed for 5 seconds
- **Slow Motion** (⏳): Slows down gameplay for 8 seconds
- **Invincibility** (🛡️): Pass through walls and self for 5 seconds
- **Double Points** (2X): All food gives double points for 10 seconds
- **Extra Life** (❤️): Adds one additional life

### 🎨 Visual Themes
- **Classic**: Traditional green snake on black background
- **Neon**: Cyberpunk-style with glowing effects and cyan colors
- **Space**: Deep space theme with indigo and blue colors
- **Retro**: Vintage brown and orange color scheme

### 🎵 Audio & Feedback
- **Sound Effects**: Game start, food eating, power-ups, collisions, level up
- **Vibration Feedback**: Haptic feedback on mobile devices
- **Visual Animations**: Smooth transitions and particle effects

### 📊 Statistics & Persistence
- **High Score System**: Persistent high score storage
- **Game Statistics**: Total games played, total score, longest snake
- **Local Storage**: All data saved locally using SharedPreferences

### 🎮 Controls
- **Touch Controls**: On-screen directional buttons
- **Keyboard Support**: Arrow keys or WASD for desktop
- **Gesture Support**: Swipe gestures (can be added)

### 🔧 Advanced Features
- **State Management**: Clean architecture using Provider
- **Responsive Design**: Works on all screen sizes
- **Cross-Platform**: Runs on iOS, Android, Web, Desktop
- **Modern UI**: Material Design 3 with custom fonts
- **Settings Menu**: Customize difficulty, theme, and sound

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Chrome (for web testing)

### Installation
1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd snake_game
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the game:
   ```bash
   # For web
   flutter run -d chrome
   
   # For mobile (with device connected)
   flutter run
   
   # For desktop
   flutter run -d windows  # or macos/linux
   ```

## 🎮 How to Play

1. **Start the Game**: Tap "Start Game" to begin
2. **Control the Snake**: Use directional buttons or keyboard arrows
3. **Eat Food**: Guide your snake to eat different types of food
4. **Collect Power-ups**: Grab special power-ups for temporary abilities
5. **Avoid Collisions**: Don't hit walls or yourself (unless invincible)
6. **Level Up**: Reach 100 points to advance to the next level
7. **Beat High Scores**: Try to achieve the highest score possible!

### Keyboard Controls
- **Arrow Keys** or **WASD**: Move snake
- **Spacebar**: Start/Pause game
- **ESC**: Open settings menu

## 🏗️ Architecture

The game follows a clean architecture pattern:

- **State Management**: Provider pattern for reactive state updates
- **Game Engine**: Custom game loop with configurable timing
- **Modular Design**: Separate classes for different game entities
- **Theme System**: Pluggable theme architecture
- **Sound System**: Async audio management
- **Storage**: Persistent data using SharedPreferences

## 📱 Supported Platforms

- ✅ **iOS**: Full feature support
- ✅ **Android**: Full feature support with haptic feedback
- ✅ **Web**: Complete web experience
- ✅ **Windows**: Desktop with keyboard controls
- ✅ **macOS**: Native macOS experience
- ✅ **Linux**: Linux desktop support

## 🎯 Game Mechanics

### Scoring System
- Normal food: 10 points
- Golden food: 50 points
- Rainbow food: 30 points
- Toxic food: -20 points (if not invincible)
- Double points power-up: 2x multiplier

### Difficulty Scaling
- **Easy**: 300ms base speed
- **Medium**: 200ms base speed  
- **Hard**: 150ms base speed
- **Insane**: 100ms base speed

Speed decreases by 10ms per level (minimum 50ms).

### Power-up Spawn Rate
- Power-ups spawn randomly every 15 seconds
- 50% chance of spawning when conditions are met
- Only one power-up active at a time per type

## 🔧 Customization

### Adding New Themes
1. Add new theme to `GameTheme` enum
2. Update `_getThemeDecoration()` method
3. Add theme selection in settings dialog

### Adding New Power-ups
1. Add new type to `PowerUpType` enum
2. Implement logic in `activatePowerUp()` method
3. Add visual representation in `_buildPowerUp()`

### Adding Sound Effects
1. Add sound files to `assets/sounds/` directory
2. Update `pubspec.yaml` to include assets
3. Update `playSound()` method with new sound names

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the beautiful UI components
- All the package authors for the excellent plugins used

---

**Enjoy playing the most powerful Snake game ever built! 🐍✨**