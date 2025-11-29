const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 1 << 24);
}

pub const MulToken = struct {
    val1: u32,
    val2: u32,
};

const Token = union(enum) {
    do,
    dont,
    mul: MulToken,
};

pub const TokenIterator = struct {
    contents: []const u8,
    index: usize = 0,

    const max_int_length = 3;

    const match_mul = "mul(";
    const match_do = "do()";
    const match_dont = "don't()";

    pub fn init(contents: []const u8) TokenIterator {
        return .{
            .contents = contents,
        };
    }

    pub fn next(self: *TokenIterator) ?Token {
        while (self.index + match_mul.len <= self.contents.len) {
            const current_slice = self.contents[self.index..];
            if (self.strEqual(match_mul, current_slice)) |slice| {
                if (parseMul(slice)) |token| {
                    return Token{ .mul = token };
                }
            } else if (self.strEqual(match_do, current_slice)) |_| {
                return Token{ .do = {} };
            } else if (self.strEqual(match_dont, current_slice)) |_| {
                return Token{ .dont = {} };
            }

            self.index += 1;
        } else return null;
    }

    fn strEqual(self: *TokenIterator, match: []const u8, slice: []const u8) ?[]const u8 {
        if (slice.len < match.len or !std.mem.eql(u8, match, slice[0..match.len])) {
            return null;
        }

        self.index += match.len;
        return slice[match.len..];
    }

    pub fn parseMul(slice: []const u8) ?MulToken {
        var comma_iterator = std.mem.splitScalar(u8, slice, ',');
        const first = comma_iterator.first();

        const rest = comma_iterator.rest();
        const index_of_end = std.mem.indexOfScalar(u8, rest, ')') orelse return null;
        const second = rest[0..index_of_end];

        if (first.len > max_int_length or second.len > max_int_length)
            return null;

        return .{
            .val1 = std.fmt.parseInt(u32, first, 10) catch return null,
            .val2 = std.fmt.parseInt(u32, second, 10) catch return null,
        };
    }
};
