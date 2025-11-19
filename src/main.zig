const std = @import("std");
const Random = std.Random;
const ArrayList = std.ArrayList;

// ANSI color codes for terminal output
const Color = struct {
    const RESET = "\x1b[0m";
    const BOLD = "\x1b[1m";
    const RED = "\x1b[31m";
    const GREEN = "\x1b[32m";
    const YELLOW = "\x1b[33m";
    const BLUE = "\x1b[34m";
    const MAGENTA = "\x1b[35m";
    const CYAN = "\x1b[36m";
    const WHITE = "\x1b[37m";
    const ORANGE = "\x1b[38;5;208m";

    // Background colors for code pegs
    const BG_RED = "\x1b[41m";
    const BG_GREEN = "\x1b[42m";
    const BG_YELLOW = "\x1b[43m";
    const BG_BLUE = "\x1b[44m";
    const BG_MAGENTA = "\x1b[45m";
    const BG_ORANGE = "\x1b[48;5;208m";
};

// Game symbols representing colored pegs
const Symbol = enum(u8) {
    Red = 'R',
    Green = 'G',
    Blue = 'B',
    Yellow = 'Y',
    Orange = 'O',
    Purple = 'P',

    pub fn fromChar(c: u8) ?Symbol {
        return switch (c) {
            'R', 'r' => .Red,
            'G', 'g' => .Green,
            'B', 'b' => .Blue,
            'Y', 'y' => .Yellow,
            'O', 'o' => .Orange,
            'P', 'p' => .Purple,
            else => null,
        };
    }

    pub fn toChar(self: Symbol) u8 {
        return @intFromEnum(self);
    }

    pub fn getColor(self: Symbol) []const u8 {
        return switch (self) {
            .Red => Color.RED,
            .Green => Color.GREEN,
            .Blue => Color.BLUE,
            .Yellow => Color.YELLOW,
            .Orange => Color.ORANGE,
            .Purple => Color.MAGENTA,
        };
    }

    pub fn getBgColor(self: Symbol) []const u8 {
        return switch (self) {
            .Red => Color.BG_RED,
            .Green => Color.BG_GREEN,
            .Blue => Color.BG_BLUE,
            .Yellow => Color.BG_YELLOW,
            .Orange => Color.BG_ORANGE,
            .Purple => Color.BG_MAGENTA,
        };
    }

    pub fn getName(self: Symbol) []const u8 {
        return switch (self) {
            .Red => "Red",
            .Green => "Green",
            .Blue => "Blue",
            .Yellow => "Yellow",
            .Orange => "Orange",
            .Purple => "Purple",
        };
    }
};

const CODE_LENGTH = 4;
const MAX_ATTEMPTS = 10;
const ALL_SYMBOLS = [_]Symbol{ .Red, .Green, .Blue, .Yellow, .Orange, .Purple };

const Game = struct {
    secret_code: [CODE_LENGTH]Symbol,
    attempts: usize,
    won: bool,

    pub fn init(random: Random) Game {
        var code: [CODE_LENGTH]Symbol = undefined;
        for (&code) |*peg| {
            peg.* = ALL_SYMBOLS[random.intRangeAtMost(usize, 0, ALL_SYMBOLS.len - 1)];
        }

        return Game{
            .secret_code = code,
            .attempts = 0,
            .won = false,
        };
    }

    pub fn checkGuess(self: *Game, guess: [CODE_LENGTH]Symbol) struct { exact: usize, color: usize } {
        var exact: usize = 0;
        var color: usize = 0;
        var secret_used = [_]bool{false} ** CODE_LENGTH;
        var guess_used = [_]bool{false} ** CODE_LENGTH;

        // First pass: count exact matches
        for (guess, 0..) |peg, i| {
            if (peg == self.secret_code[i]) {
                exact += 1;
                secret_used[i] = true;
                guess_used[i] = true;
            }
        }

        // Second pass: count color matches (correct color, wrong position)
        for (guess, 0..) |peg, i| {
            if (!guess_used[i]) {
                for (self.secret_code, 0..) |secret_peg, j| {
                    if (!secret_used[j] and peg == secret_peg) {
                        color += 1;
                        secret_used[j] = true;
                        break;
                    }
                }
            }
        }

        return .{ .exact = exact, .color = color };
    }

    pub fn makeGuess(self: *Game, guess: [CODE_LENGTH]Symbol) bool {
        self.attempts += 1;
        const result = self.checkGuess(guess);

        if (result.exact == CODE_LENGTH) {
            self.won = true;
            return true;
        }

        return false;
    }
};

fn printWelcome() void {
    const stdout = std.io.getStdOut().writer();
    stdout.print("\n{s}{s}╔═══════════════════════════════════════════════════╗{s}\n", .{ Color.BOLD, Color.CYAN, Color.RESET }) catch {};
    stdout.print("{s}{s}║           🧩 CIPHERMIND - MASTERMIND 🧩          ║{s}\n", .{ Color.BOLD, Color.CYAN, Color.RESET }) catch {};
    stdout.print("{s}{s}╚═══════════════════════════════════════════════════╝{s}\n\n", .{ Color.BOLD, Color.CYAN, Color.RESET }) catch {};

    stdout.print("{s}Welcome to CipherMind!{s}\n", .{ Color.BOLD, Color.RESET }) catch {};
    stdout.print("Crack the secret code using logic and deduction.\n\n", .{}) catch {};

    stdout.print("{s}How to Play:{s}\n", .{ Color.YELLOW, Color.RESET }) catch {};
    stdout.print("• The secret code is {s}4 colored pegs{s}\n", .{ Color.BOLD, Color.RESET }) catch {};
    stdout.print("• Available colors: ", .{}) catch {};
    for (ALL_SYMBOLS, 0..) |sym, i| {
        stdout.print("{s}{c}{s}", .{ sym.getColor(), sym.toChar(), Color.RESET }) catch {};
        if (i < ALL_SYMBOLS.len - 1) {
            stdout.print(", ", .{}) catch {};
        }
    }
    stdout.print("\n", .{}) catch {};
    stdout.print("  ({s}R{s}ed, {s}G{s}reen, {s}B{s}lue, {s}Y{s}ellow, {s}O{s}range, {s}P{s}urple)\n", .{
        Color.RED,     Color.RESET,
        Color.GREEN,   Color.RESET,
        Color.BLUE,    Color.RESET,
        Color.YELLOW,  Color.RESET,
        Color.ORANGE,  Color.RESET,
        Color.MAGENTA, Color.RESET,
    }) catch {};
    stdout.print("• You have {s}{d} attempts{s} to crack the code\n", .{ Color.BOLD, MAX_ATTEMPTS, Color.RESET }) catch {};
    stdout.print("• After each guess, you'll receive feedback:\n", .{}) catch {};
    stdout.print("  {s}●{s} = Correct color in correct position\n", .{ Color.GREEN, Color.RESET }) catch {};
    stdout.print("  {s}○{s} = Correct color in wrong position\n\n", .{ Color.YELLOW, Color.RESET }) catch {};
    stdout.print("{s}Let's begin! Good luck!{s}\n\n", .{ Color.BOLD, Color.RESET }) catch {};
}

fn printColoredCode(code: [CODE_LENGTH]Symbol) void {
    const stdout = std.io.getStdOut().writer();
    stdout.print("[ ", .{}) catch {};
    for (code, 0..) |peg, i| {
        stdout.print("{s} {c} {s}", .{ peg.getBgColor(), peg.toChar(), Color.RESET }) catch {};
        if (i < code.len - 1) {
            stdout.print(" ", .{}) catch {};
        }
    }
    stdout.print(" ]", .{}) catch {};
}

fn printFeedback(exact: usize, color: usize, attempts: usize) void {
    const stdout = std.io.getStdOut().writer();

    stdout.print("  → ", .{}) catch {};

    // Print exact matches
    var i: usize = 0;
    while (i < exact) : (i += 1) {
        stdout.print("{s}●{s} ", .{ Color.GREEN, Color.RESET }) catch {};
    }

    // Print color matches
    i = 0;
    while (i < color) : (i += 1) {
        stdout.print("{s}○{s} ", .{ Color.YELLOW, Color.RESET }) catch {};
    }

    stdout.print("({s}{d} exact{s}, {s}{d} color{s})", .{
        Color.GREEN,
        exact,
        Color.RESET,
        Color.YELLOW,
        color,
        Color.RESET,
    }) catch {};

    // Encouraging messages
    if (exact == 0 and color == 0) {
        stdout.print(" {s}Try different colors!{s}", .{ Color.CYAN, Color.RESET }) catch {};
    } else if (exact == CODE_LENGTH - 1) {
        stdout.print(" {s}So close! One more!{s}", .{ Color.MAGENTA, Color.RESET }) catch {};
    } else if (exact >= 2) {
        stdout.print(" {s}Great progress!{s}", .{ Color.MAGENTA, Color.RESET }) catch {};
    } else if (color >= 2) {
        stdout.print(" {s}Right colors, wrong positions!{s}", .{ Color.CYAN, Color.RESET }) catch {};
    } else if (exact + color >= 2) {
        stdout.print(" {s}You're getting warmer!{s}", .{ Color.CYAN, Color.RESET }) catch {};
    }

    stdout.print("\n\n", .{}) catch {};
}

fn readGuess(allocator: std.mem.Allocator) ![CODE_LENGTH]Symbol {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    while (true) {
        stdout.print("Enter your guess ({d} colors, e.g., RGBY): ", .{CODE_LENGTH}) catch {};

        const input = try stdin.readUntilDelimiterAlloc(allocator, '\n', 100);
        defer allocator.free(input);

        // Trim whitespace
        const trimmed = std.mem.trim(u8, input, &std.ascii.whitespace);

        // Check length
        if (trimmed.len != CODE_LENGTH) {
            stdout.print("{s}Invalid input! Please enter exactly {d} colors.{s}\n\n", .{
                Color.RED,
                CODE_LENGTH,
                Color.RESET,
            }) catch {};
            continue;
        }

        // Parse symbols
        var guess: [CODE_LENGTH]Symbol = undefined;
        var valid = true;

        for (trimmed, 0..) |c, i| {
            if (Symbol.fromChar(c)) |sym| {
                guess[i] = sym;
            } else {
                stdout.print("{s}Invalid color '{c}'! Use: R, G, B, Y, O, P{s}\n\n", .{
                    Color.RED,
                    c,
                    Color.RESET,
                }) catch {};
                valid = false;
                break;
            }
        }

        if (valid) {
            return guess;
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    // Initialize random number generator
    var prng = std.Random.DefaultPrng.init(@intCast(std.time.timestamp()));
    const random = prng.random();

    printWelcome();

    // Outer loop for playing multiple games
    while (true) {
        var game = Game.init(random);

        // Main game loop
        while (game.attempts < MAX_ATTEMPTS and !game.won) {
            stdout.print("{s}═══ Attempt {d}/{d} ═══{s}\n", .{
                Color.CYAN,
                game.attempts + 1,
                MAX_ATTEMPTS,
                Color.RESET,
            }) catch {};

            const guess = try readGuess(allocator);

            stdout.print("\nYour guess: ", .{}) catch {};
            printColoredCode(guess);
            stdout.print("\n", .{}) catch {};

            const result = game.checkGuess(guess);

            if (game.makeGuess(guess)) {
                // Won!
                stdout.print("\n{s}{s}🎉 CONGRATULATIONS! 🎉{s}\n", .{
                    Color.BOLD,
                    Color.GREEN,
                    Color.RESET,
                }) catch {};
                stdout.print("{s}You cracked the code in {d} attempt{s}!{s}\n", .{
                    Color.GREEN,
                    game.attempts,
                    if (game.attempts == 1) "" else "s",
                    Color.RESET,
                }) catch {};
                stdout.print("\nThe secret code was: ", .{}) catch {};
                printColoredCode(game.secret_code);
                stdout.print("\n", .{}) catch {};

                if (game.attempts <= 4) {
                    stdout.print("\n{s}Outstanding! You're a master codebreaker!{s}\n", .{
                        Color.MAGENTA,
                        Color.RESET,
                    }) catch {};
                } else if (game.attempts <= 7) {
                    stdout.print("\n{s}Excellent work! Great logical thinking!{s}\n", .{
                        Color.MAGENTA,
                        Color.RESET,
                    }) catch {};
                } else {
                    stdout.print("\n{s}Well done! You solved it!{s}\n", .{
                        Color.MAGENTA,
                        Color.RESET,
                    }) catch {};
                }
                break;
            } else {
                printFeedback(result.exact, result.color, game.attempts);
            }
        }

        // Lost
        if (!game.won) {
            stdout.print("\n{s}{s}💔 GAME OVER 💔{s}\n", .{
                Color.BOLD,
                Color.RED,
                Color.RESET,
            }) catch {};
            stdout.print("{s}You've run out of attempts!{s}\n", .{ Color.RED, Color.RESET }) catch {};
            stdout.print("\nThe secret code was: ", .{}) catch {};
            printColoredCode(game.secret_code);
            stdout.print("\n\n{s}Better luck next time! Try again?{s}\n", .{
                Color.YELLOW,
                Color.RESET,
            }) catch {};
        }

        // Play again?
        stdout.print("\n{s}Play again? (y/n): {s}", .{ Color.BOLD, Color.RESET }) catch {};
        var buf: [10]u8 = undefined;
        if (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |input| {
            const trimmed = std.mem.trim(u8, input, &std.ascii.whitespace);
            if (trimmed.len > 0 and (trimmed[0] == 'y' or trimmed[0] == 'Y')) {
                stdout.print("\n", .{}) catch {};
                // Continue to next iteration to start a new game
                continue;
            }
        }

        // User chose not to play again or input ended
        break;
    }

    stdout.print("\n{s}Thanks for playing CipherMind! 🧩{s}\n\n", .{
        Color.CYAN,
        Color.RESET,
    }) catch {};
}
