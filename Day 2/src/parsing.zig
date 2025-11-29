const std = @import("std");

pub const LevelData = std.ArrayList(i32);
pub const LevelDataList = struct {
    list: std.ArrayList(LevelData),

    pub fn init(allocator: std.mem.Allocator) !LevelDataList {
        return .{
            .list = try std.ArrayList(LevelData).initCapacity(allocator, 0),
        };
    }

    pub fn deinit(self: *LevelDataList, allocator: std.mem.Allocator) void {
        for (self.list.items) |*level_data| {
            level_data.deinit(allocator);
        }

        self.list.deinit(allocator);
    }
};

pub fn readFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 1 << 24);
}

pub fn parseLevelData(allocator: std.mem.Allocator, level_data_list: *LevelDataList, contents: []u8) !void {
    var line_iterator = std.mem.splitScalar(u8, contents, '\n');
    while (line_iterator.next()) |line| {
        var level_data = try LevelData.initCapacity(allocator, 0);

        var whitespace_iterator = std.mem.tokenizeAny(u8, line, " ");
        while (whitespace_iterator.next()) |token| {
            try level_data.append(allocator, try std.fmt.parseInt(i32, token, 10));
        }

        if (level_data.items.len > 0) {
            try level_data_list.list.append(allocator, level_data);
        }
    }
}
