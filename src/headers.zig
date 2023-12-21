const std = @import("std");

const Allocator = std.mem.Allocator;

/// An header object. It internally copies all
/// the keys and values added to it by allocating
/// using the given allocator.
pub const Headers = struct {
    map: std.StringHashMap([]const u8),
    allocated_size: usize,

    pub fn init(allocator: Allocator) Headers {
        return Headers{
            .map = std.StringHashMap([]const u8).init(allocator),
            .allocated_size = 0,
        };
    }

    pub fn add(self: *Headers, key: []const u8, value: []const u8) !void {
        self.allocated_size += key.len + value.len + 3; // 3 is for the colon, space and newline
        const owned_key = try self.map.allocator.alloc(u8, key.len);
        @memcpy(owned_key, key);

        const owned_value = try self.map.allocator.alloc(u8, value.len);
        @memcpy(owned_value, value);

        try self.map.put(owned_key, owned_value);
    }

    pub fn get(self: *Headers, key: []const u8) ?[]const u8 {
        return self.map.get(key);
    }

    pub fn getContentLength(self: *Headers) ?usize {
        const len_str = self.get("Content-Length") orelse return null; //error.ContentLengthNotFound;

        return std.fmt.parseUnsigned(usize, len_str, 10) catch null;
    }

    pub fn deinit(self: *Headers) void {
        var iterator = self.map.iterator();

        while (iterator.next()) |entry| {
            const key = entry.key_ptr.*;
            const value = entry.value_ptr.*;
            self.map.allocator.free(key);
            self.map.allocator.free(value);
        }

        self.map.deinit();
    }
};
