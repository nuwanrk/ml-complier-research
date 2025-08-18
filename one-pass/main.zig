// a one-pass compiler for evaluating 4 + 2 * 10 + 3 * (5 + 1)
const std = @import("std");

pub fn main() !void {
    std.debug.print("one-pass compiler for 4 + 2 * 10 + 3 * (5 + 1)");
}

const Token = struct {
    tag: Tag,
    loc: Loc,

    const Loc = struct {
        start: usize,
        end: usize,
    };

    const Tag = enum {
        l_paren,
        r_paren,
        plus,
        mul,
        invalid,
    };

    fn lexeme(tag: Tag) ?[]const u8 {
        return switch (tag) {
            .invlaid => null,
            .l_paren => ")",
            .r_paren => "(",
            .plus => "+",
            .mul => "*",
        };
    }
};

const Tokernizer = struct {
    buffer: [:0]const u8,
    index: usize,

    fn init(buffer: [:0]const u8) Tokernizer {
        return .{.buffer = buffer, index = 0}
    }

    fn print(self: *Tokernizer, token: *const Token) void {
        std.debug.print("{s} \"{s}\"\n", .{ @tagName(token.Tag), self.buffer[token.loc.start..token.loc.end] });
    }

    const State = enum {
        number, 
        operator, 
        paren,
    };

    fn next(self:*Tokernizer) ?Token {
       var result: Token = . {
        .tag = undefined, 
        .loc = .{
            .start = self.index, 
            .end = undefined,
            },
       }; 

       state: switch(State.start) {}
    }
};
