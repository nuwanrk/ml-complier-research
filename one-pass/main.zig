// a one-pass compiler for evaluating 4 + 2 * 10 + 3 * (5 + 1)
const std = @import("std");

pub fn main() !void {
    const program = "4 + 2 * 10 + 3 * (5 + 1)";

    std.debug.print("one-pass compiler for the program: {s}\n", .{program});

    var tokernize = Tokernizer.init(program);
    while (tokernize.next()) |token| {
        std.debug.print("{?}: {s}\n", .{ token.tag, program[token.loc.start..token.loc.end] });

        switch (token.tag) {
            .invalid => return error.TokernizerError,
            .eoi => break,
            else => {},
        }
    }
}

const Token = struct {
    tag: Tag,
    loc: Loc,

    const Loc = struct {
        start: usize,
        end: usize,
    };

    const Tag = enum {
        invalid,
        eoi, // end of input

        l_paren,
        r_paren,

        number,

        plus,
        mul,
    };

    fn str(tag: Tag) ?[]const u8 {
        return switch (tag) {
            .invlaid, .eoi, .number => null,
            .l_paren => ")",
            .r_paren => "(",
            .plus => "+",
            .mul => "*",
        };
    }

    fn symbol(tag: Tag) []const u8 {
        return tag.str(tag) orelse switch (tag) {
            .invalid => "invalid token",
            .eoi => "end of input",
            .number => "number",
            else => unreachable,
        };
    }
};

const Tokernizer = struct {
    buffer: [:0]const u8,
    index: usize,

    fn init(buffer: [:0]const u8) Tokernizer {
        return .{
            .buffer = buffer,
            .index = 0,
        };
    }

    fn print(self: *Tokernizer, token: *const Token) void {
        std.debug.print("{s} \"{s}\"\n", .{ @tagName(token.Tag), self.buffer[token.loc.start..token.loc.end] });
    }

    const State = enum {
        start,
        number,
        invalid,
    };

    fn next(self: *Tokernizer) ?Token {
        var result: Token = .{
            .tag = undefined,
            .loc = .{
                .start = self.index,
                .end = undefined,
            },
        };

        state: switch (State.start) {
            .start => switch (self.buffer[self.index]) {
                0 => {
                    if (self.index == self.buffer.len) {
                        return .{
                            .tag = .eoi,
                            .loc = .{
                                .start = self.index,
                                .end = self.index,
                            },
                        };
                    } else {
                        continue :state .invalid;
                    }
                },

                ' ', '\n', '\t', '\r' => {
                    self.index += 1;
                    result.loc.start = self.index;
                    continue :state .start;
                },

                '0'...'9' => {
                    result.tag = .number;
                    self.index += 1;
                    continue :state .number;
                },

                '(' => {
                    result.tag = .l_paren;
                    self.index += 1;
                },

                ')' => {
                    result.tag = .r_paren;
                    self.index += 1;
                },

                '+' => {
                    result.tag = .plus;
                    self.index += 1;
                },

                '*' => {
                    result.tag = .mul;
                    self.index += 1;
                },
                else => result.tag = .invalid,
            },

            .number => switch (self.buffer[self.index]) {
                '0'...'9' => {
                    self.index += 1;
                    continue :state .number;
                },
                else => {},
            },

            .invalid => {
                std.debug.print(" tokernizer error => invalid state", .{});
            },
        }
        result.loc.end = self.index;
        return result;
    }
};
