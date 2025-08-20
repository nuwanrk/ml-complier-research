// implement a simple rule engine with AST
// evaluate the rule: price > 100 AND stock < 50
const std = @import("std");

pub fn main() !void {
    const rule = "price > 100 AND stock < 50";
    std.debug.print("rule: {s}\n", .{rule});
    var tokernizer = Tokernizer.init(rule);
    while (tokernizer.next()) |token| {
        std.debug.print("{?}: {s}\n", .{ token.tag, rule[token.loc.start..token.loc.end] });

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
        eoi,
        variable,

        less_than,
        greater_than,
        number,

        keyword_and,
    };

    const keywords = std.StaticStringMap(Tag).initComptime(.{.{ "AND", .keyword_and }});

    fn str(tag: Tag) ?[]const u8 {
        return switch (tag) {
            .invalid => "invalid token",
            .eoi => "end of input",
            .number => "number",
            .less_than => "<",
            .greater_than => ">",
            .number => "number",
            .keyword_and => "AND",
            .variable => "variable",
            else => unreachable,
        };
    }

    fn getKeyword(keyword: []const u8) ?Tag {
        return keywords.get(keyword);
    }
};

const Tokernizer = struct {
    buffer: [:0]const u8,
    index: usize,

    fn init(buffer: [:0]const u8) Tokernizer {
        return .{ .buffer = buffer, .index = 0 };
    }

    const State = enum {
        start,
        number,
        invalid,
        variable,
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

                'a'...'z', 'A'...'Z' => {
                    result.tag = .variable;
                    continue :state .variable;
                },

                '<' => {
                    result.tag = .less_than;
                    self.index += 1;
                },

                '>' => {
                    result.tag = .greater_than;
                    self.index += 1;
                },

                else => result.tag = .invalid,
            },

            .variable => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    'a'...'z', 'A'...'Z' => continue :state .variable,
                    else => {
                        const ident = self.buffer[result.loc.start..self.index];
                        if (Token.getKeyword(ident)) |tag| {
                            result.tag = tag;
                        }
                    },
                }
            },

            .number => switch (self.buffer[self.index]) {
                '0'...'9' => {
                    self.index += 1;
                    continue :state .number;
                },
                else => {},
            },

            .invalid => {
                std.debug.print("tokernizer error => invalid state", .{});
            },
        }
        result.loc.end = self.index;
        return result;
    }
};
