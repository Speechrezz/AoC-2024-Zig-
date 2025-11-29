const std = @import("std");
const parsing = @import("parsing.zig");

fn part1_is_safe(level_data: parsing.LevelData) bool {
    var prev_value = level_data.items[0];
    const is_increasing = prev_value < level_data.items[1];

    for (level_data.items[1..]) |current_value| {
        const difference = current_value - prev_value;
        const is_correct_direction = (is_increasing and difference > 0) or (!is_increasing and difference < 0);
        const is_safe_distance = @abs(difference) <= 3;

        if (!is_correct_direction or !is_safe_distance) {
            return false;
        }

        prev_value = current_value;
    }

    return true;
}

fn part1(level_data_list: *parsing.LevelDataList) u32 {
    var safe_count: u32 = 0;

    for (level_data_list.list.items) |level_data| {
        safe_count += @intCast(@intFromBool(part1_is_safe(level_data)));
    }

    return safe_count;
}

fn part2_is_increasing(level_data: parsing.LevelData) bool {
    var prev_value = level_data.items[0];
    var increasing_count: i32 = 0;

    for (level_data.items[1..]) |current_value| {
        increasing_count += @intCast(@intFromBool(current_value > prev_value));
        increasing_count -= @intCast(@intFromBool(current_value < prev_value));

        prev_value = current_value;
    }

    return increasing_count > 0;
}

fn part2_is_safe(level_data: parsing.LevelData, is_increasing: bool, skip_index: usize) bool {
    const start_index: usize = if (skip_index == 0) 2 else 1;
    var prev_value = level_data.items[start_index - 1];

    for (level_data.items[start_index..], start_index..) |current_value, i| {
        if (i == skip_index) continue;

        const difference = current_value - prev_value;
        const is_correct_direction = (is_increasing and difference > 0) or (!is_increasing and difference < 0);
        const is_safe_distance = @abs(difference) <= 3;

        if (!is_correct_direction or !is_safe_distance) {
            return false;
        }

        prev_value = current_value;
    }

    return true;
}

fn part2(level_data_list: *parsing.LevelDataList) u32 {
    var safe_count: u32 = 0;

    for (level_data_list.list.items) |level_data| {
        // Brute-force try skipping individual elements
        const is_increasing = part2_is_increasing(level_data);
        const is_safe =
            for (0..level_data.items.len) |skip_index| {
                if (part2_is_safe(level_data, is_increasing, skip_index)) {
                    break true;
                }
            } else false;

        safe_count += @intCast(@intFromBool(is_safe));
    }

    return safe_count;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open the file
    const contents = try parsing.readFile(allocator, "input.txt");
    defer allocator.free(contents);

    // Parse
    var level_data_list = try parsing.LevelDataList.init(allocator);
    defer level_data_list.deinit(allocator);
    try parsing.parseLevelData(allocator, &level_data_list, contents);

    // Solve
    std.debug.print("[Part 1] Solution={}\n", .{part1(&level_data_list)});
    std.debug.print("[Part 2] Solution={}\n", .{part2(&level_data_list)});
}
