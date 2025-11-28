const std = @import("std");
const parsing = @import("parsing.zig");

fn part1(array_pair: *parsing.ArrayPair) usize {
    // Sort
    std.sort.block(i32, array_pair.list1.items, {}, comptime std.sort.asc(i32));
    std.sort.block(i32, array_pair.list2.items, {}, comptime std.sort.asc(i32));

    // Sum distances
    var sum: u32 = 0;
    for (array_pair.list1.items, array_pair.list2.items) |val1, val2| {
        sum += @abs(val1 - val2);
    }

    return sum;
}

fn part2(array_pair: *parsing.ArrayPair) usize {
    var sum: u32 = 0;
    for (array_pair.list1.items) |val1| {
        var count: u32 = 0;
        for (array_pair.list2.items) |val2| {
            count += @intCast(@intFromBool(val1 == val2));
        }

        sum += count * @as(u32, @intCast(val1));
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

    // Parse
    var array_pair = try parsing.ArrayPair.init(allocator);
    defer array_pair.deinit();
    try parsing.parseList(contents, &array_pair);

    // Solve
    var array_pair_part1 = try array_pair.clone();
    defer array_pair_part1.deinit();

    std.debug.print("[Part 1] Result={}\n", .{part1(&array_pair_part1)});
    std.debug.print("[Part 2] Result={}\n", .{part2(&array_pair)});
}
