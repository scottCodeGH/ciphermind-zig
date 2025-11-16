# 🧩 CipherMind - Mastermind Puzzle Game in Zig

A smart and fun terminal-based code-breaking puzzle game inspired by the classic Mastermind board game. Built with Zig to showcase performance, safety, and the power of systems programming for creating engaging console experiences.

## 🎮 Game Overview

CipherMind is a logic puzzle where you must crack a secret code through deduction and reasoning. The computer generates a random 4-color code, and you have 10 attempts to guess it. After each guess, you receive feedback clues to help narrow down the possibilities.

**Perfect for:**
- Quick brain-teasing sessions (5-10 minutes)
- Logic and deduction practice
- Casual puzzle enthusiasts
- Anyone who enjoys a mental challenge!

## 🎯 How to Play

1. **The Challenge**: The game creates a secret code using 4 colored pegs
2. **Available Colors**:
   - 🔴 **R**ed
   - 🟢 **G**reen
   - 🔵 **B**lue
   - 🟡 **Y**ellow
   - 🟠 **O**range
   - 🟣 **P**urple

3. **Make Your Guess**: Enter 4 letters representing colors (e.g., `RGBY`)

4. **Receive Feedback**:
   - 🟢 **● (Green dot)** = Correct color in the correct position
   - 🟡 **○ (Yellow circle)** = Correct color but in the wrong position

5. **Win Condition**: Crack the code within 10 attempts!

### Example Game Flow

```
Enter your guess (4 colors, e.g., RGBY): RGBY
Your guess: [ R  G  B  Y ]
  → ● ○ (1 exact, 1 color) You're getting warmer!

Enter your guess (4 colors, e.g., RGBY): RGYB
Your guess: [ R  G  Y  B ]
  → ● ● (2 exact, 0 color) Great progress!

Enter your guess (4 colors, e.g., RGBY): RGYO
Your guess: [ R  G  Y  O ]
  → ● ● ● ○ (3 exact, 1 color) So close! One more!

Enter your guess (4 colors, e.g., RGBY): ROGY
Your guess: [ R  O  G  Y ]
  → ● ● ● ● (4 exact, 0 color)

🎉 CONGRATULATIONS! 🎉
You cracked the code in 4 attempts!
```

## 🚀 Building and Running

### Prerequisites

- [Zig](https://ziglang.org/download/) (0.11.0 or later)

### Build the Game

```bash
# Clone the repository
git clone https://github.com/scottCodeGH/ciphermind-zig.git
cd ciphermind-zig

# Build and run
zig build run

# Or build the executable
zig build

# Then run it
./zig-out/bin/ciphermind
```

### Run Tests

```bash
zig build test
```

## 🎨 Features

- ✨ **Colorful Terminal UI**: ANSI colors make the text-based interface vibrant and easy to read
- 🎲 **Random Code Generation**: Every game is unique with randomly generated codes
- 🧠 **Smart Feedback System**: Precise clues help you deduce the solution logically
- 💪 **Robust Input Validation**: Handles invalid input gracefully without crashes
- 🎭 **Encouraging Messages**: Fun flavor text keeps you engaged throughout the game
- ⚡ **High Performance**: Built with Zig for speed and reliability
- 🔒 **Memory Safe**: Leverages Zig's safety features for crash-free gameplay
- 🔄 **Play Again**: Quick restart option for endless puzzle-solving fun

## 🧪 Technical Highlights

This game demonstrates several Zig programming concepts:

- **Random Number Generation**: Using Zig's `std.Random` for unpredictable codes
- **Enum-based Design**: Type-safe color representation
- **Error Handling**: Graceful input validation and error recovery
- **Standard I/O**: Efficient terminal input/output operations
- **Memory Management**: Proper allocator usage with GeneralPurposeAllocator
- **ANSI Escape Codes**: Cross-platform terminal colors and formatting
- **Game Loop Architecture**: Clean state management and turn-based flow

## 🎓 Strategy Tips

1. **Start with variety**: Try using different colors in your first guess to gather maximum information
2. **Process elimination**: Use the feedback to eliminate impossible combinations
3. **Track your guesses**: Remember what you've tried and what the feedback revealed
4. **Position matters**: A color match (○) means the color exists but isn't in that spot
5. **Exact matches first**: Focus on locking in positions where you have exact matches (●)

## 📝 Game Rules

- The secret code is 4 pegs long
- Colors can repeat (e.g., `RRGG` is valid)
- You have 10 attempts to crack the code
- Feedback is given after each guess
- Case-insensitive input (both `RGBY` and `rgby` work)

## 🏆 Difficulty Levels

Your performance rating based on attempts needed:
- **1-4 attempts**: 🌟 Master Codebreaker
- **5-7 attempts**: ⭐ Excellent Logical Thinker
- **8-10 attempts**: ✨ Puzzle Solver

## 🛠️ Development

The codebase is structured for clarity and maintainability:

```
ciphermind-zig/
├── src/
│   └── main.zig        # Main game logic
├── build.zig           # Build configuration
└── README.md          # This file
```

Key components in `src/main.zig`:
- `Symbol` enum: Represents the 6 possible colors with helper methods
- `Game` struct: Manages game state and guess validation
- `checkGuess()`: Implements the Mastermind feedback algorithm
- `printColoredCode()`: Renders colored output to terminal
- `readGuess()`: Handles input validation with helpful error messages

## 🤝 Contributing

Contributions are welcome! Some ideas for enhancement:
- Difficulty levels (easier/harder codes)
- Hint system
- Score tracking across multiple games
- Timed mode
- Two-player mode

## 📜 License

This project is open source and available for educational purposes.

## 🙏 Acknowledgments

Inspired by the classic Mastermind board game invented by Mordecai Meirowitz in 1970. This digital adaptation showcases how Zig can create engaging, safe, and performant console applications.

---

**Enjoy cracking codes! 🧩✨**
