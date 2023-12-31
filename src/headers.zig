const std = @import("std");

const Allocator = std.mem.Allocator;

/// A map of headers. It internally copies all
/// the keys and values added to it by allocating
/// using the given allocator.
pub const Headers = struct {
    allocator: Allocator,
    map: std.StringHashMapUnmanaged([]const u8),
    allocated_size: usize,

    /// Initialized a new header structure
    pub fn init(allocator: Allocator) Headers {
        return Headers{
            .allocator = allocator,
            .map = std.StringHashMapUnmanaged([]const u8){},
            .allocated_size = 0,
        };
    }

    /// Sets `key` to `value`. All keys and values are duplicated using the allocator;
    pub fn set(self: *Headers, key: []const u8, value: []const u8) Allocator.Error!void {
        self.allocated_size += key.len + value.len + 3; // 3 is for the colon, space and newline
        const owned_key = try self.allocator.dupe(u8, key);
        const owned_value = try self.allocator.dupe(u8, value);

        try self.map.put(self.allocator, owned_key, owned_value);
    }

    pub fn get(self: *Headers, key: []const u8) ?[]const u8 {
        return self.map.get(key);
    }

    pub fn getContentLength(self: *Headers) ?usize {
        const len_str = self.get("Content-Length") orelse return null; //error.ContentLengthNotFound;

        return std.fmt.parseUnsigned(usize, len_str, 10) catch null;
    }

    pub fn setContentLength(self: *Headers, size: usize) Allocator.Error!void {
        // const buffer_value = std.fmt.allocPrint(self.allocator, "{d}", .{size}) catch |err| switch (err) {
        //     Allocator.Error.OutOfMemory => return err,
        //     else => unreachable,
        // };
        // defer self.allocator.free(buffer_value);
        var array_buffer: [getFmtBufferSize()]u8 = undefined;
        const buffer = std.fmt.bufPrintIntToSlice(&array_buffer, size, 10, .lower, .{});

        // std.debug.print("The buffer size is {}\n{s}\n", .{ getFmtBufferSize(), buffer });
        try self.set("Content-Length", buffer);
    }

    /// Frees all the memory
    pub fn deinit(self: *Headers) void {
        var iterator = self.map.iterator();

        while (iterator.next()) |entry| {
            const key = entry.key_ptr.*;
            const value = entry.value_ptr.*;
            self.allocator.free(key);
            self.allocator.free(value);
        }

        self.map.deinit(self.allocator);
    }
};

/// This a function to calculate the buffer size at compile time.
/// This should work from 1 bit to 2048 bit machines ༼ つ ◕_◕ ༽つ
fn getFmtBufferSize() comptime_int {
    return switch (@typeInfo(usize).Int.bits) {
        1 => 1,
        4 => 2,
        8 => 3,
        16 => 5,
        32 => 10,
        64 => 20,
        128 => 39,
        256 => 78,
        512 => 155,
        1024 => 309,
        2048 => 617,
        else => |bits| 2 * getFmtBufferSize(bits / 2),
    };
}
