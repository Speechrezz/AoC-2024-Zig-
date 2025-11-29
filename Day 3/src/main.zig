const std = @import("std");
const parsing = @import("parsing.zig");

fn part1(contents: []const u8) u32 {
    var sum: u32 = 0;
    var mul_iterator = parsing.TokenIterator.init(contents);

    while (mul_iterator.next()) |token| {
        switch (token) {
            .mul => |mul_token| sum += mul_token.val1 * mul_token.val2,
            else => {},
        }
    }

    return sum;
}

fn part2(contents: []const u8) u32 {
    var sum: u32 = 0;
    var mul_iterator = parsing.TokenIterator.init(contents);
    var is_enabled = true;

    while (mul_iterator.next()) |token| {
        switch (token) {
            .mul => |mul_token| {
                if (is_enabled) {
                    sum += mul_token.val1 * mul_token.val2;
                }
            },
            .do => is_enabled = true,
            .dont => is_enabled = false,
        }
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open the file
    const contents = try parsing.readFile(allocator, "input.txt");
    defer allocator.free(contents);

    // Solve
    std.debug.print("[Part 1] Solution={}\n", .{part1(contents)});
    std.debug.print("[Part 2] Solution={}\n", .{part2(contents)});
}
