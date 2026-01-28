# SnakeGame (MATLAB)

A classic Snake game implemented in MATLAB, featuring a graphical user interface, adjustable difficulty, and custom panels. This project is designed for both fun and as an educational example of GUI programming in MATLAB.

## Features
- Playable Snake game with keyboard controls
- Adjustable difficulty levels
- Pause and restart functionality
- Custom panels for instructions and settings
- Evasive quit button for added challenge
- Modular code structure for easy extension

## Getting Started

### Prerequisites
- MATLAB R2018b or newer (older versions may work, but are untested)

### Running the Game
1. Clone or download this repository to your local machine.
2. Open MATLAB and set the current folder to the project directory.
3. Run the main file:
   ```matlab
   SnakeGame
   ```

## File Structure
- `SnakeGame.m`: Main entry point for the game.
- `@SnakeGame/`: Contains all class methods and supporting functions:
  - `startGame.m`, `pauseGameFcn.m`, `restartGame.m`, `endGame.m`, etc.
  - UI-related: `openCustomPanel.m`, `closeCustomPanel.m`, `showInstructions.m`, `evasiveQuitButton.m`
  - Game logic: `updateDirection.m`, `updateBodyColors.m`, `updateHeadColor.m`, `setDifficulty.m`, etc.

## Documentation
Detailed documentation for each function and class is available in the `@SnakeGame/` folder. Each `.m` file contains comments explaining its purpose and usage. For an overview, see the documentation file in the project directory.

## Controls
- **Arrow keys** or **WASD**: Move the snake
- **P**: Pause/Resume
- **R**: Restart
- **Q**: Quit (try the evasive quit button!)

## Customization
You can modify the difficulty, colors, and other settings by editing the relevant files in the `@SnakeGame/` folder.

## License
This project is provided for educational and personal use. Feel free to modify and share.

## Credits
Developed by Tarniță Robert Gabriel.

---
For more details, see the in-code documentation and comments.
