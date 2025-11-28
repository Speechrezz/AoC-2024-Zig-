const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 1 << 24);
}

pub const ArrayPair = struct {
    list1: std.ArrayList(i32),
    list2: std.ArrayList(i32),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !ArrayPair {
        return .{
            .list1 = try std.ArrayList(i32).initCapacity(allocator, 0),
            .list2 = try std.ArrayList(i32).initCapacity(allocator, 0),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *ArrayPair) void {
        self.list1.deinit(self.allocator);
        self.list2.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn clone(self: *ArrayPair) !ArrayPair {
        return .{
            .list1 = try self.list1.clone(self.allocator),
            .list2 = try self.list2.clone(self.allocator),
            .allocator = self.allocator,
        };
    }
};

pub fn parseListOld(contents: []u8, array_pair: *ArrayPair) !void {
    var slice_start: usize = 0;
    var is_reading_number = false;
    var is_list1 = true;

    for (contents, 0..) |char, i| {
        if (std.ascii.isDigit(char)) {
            if (!is_reading_number) {
                is_reading_number = true;
                slice_start = i;
            }
        } else {
            if (is_reading_number) {
                is_reading_number = false;
                const slice = contents[slice_start..i];
                const value = try std.fmt.parseInt(i32, slice, 10);

                if (is_list1) {
                    try array_pair.list1.append(array_pair.allocator, value);
                } else {
                    try array_pair.list2.append(array_pair.allocator, value);
                }
                is_list1 = !is_list1;
            }
        }
    }
}

pub fn parseList(contents: []u8, array_pair: *ArrayPair) !void {
    var line_iterator = std.mem.splitScalar(u8, contents, '\n');
    while (line_iterator.next()) |line| {
        var whitespace_iterator = std.mem.tokenizeAny(u8, line, " ");
        var values = [_]i32{0} ** 2;

        inline for (0..values.len) |i| {
            const slice = whitespace_iterator.next() orelse return;
            values[i] = std.fmt.parseInt(i32, slice, 10) catch return;
        }

        try array_pair.list1.append(array_pair.allocator, values[0]);
        try array_pair.list2.append(array_pair.allocator, values[1]);
    }
}
