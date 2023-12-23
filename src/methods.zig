const std = @import("std");

/// The maximum size in bytes allowed for an HTTP/1.1 method
/// See https://http.dev/methods
const MAX_METHOD_SIZE = @import("config").MAX_METHOD_SIZE;

pub const MethodType = @Type(std.builtin.Type{ .Int = .{
    .signedness = .unsigned,
    .bits = MAX_METHOD_SIZE * 8,
} });

/// HTTP/1.1 methods
pub const Method = enum(MethodType) {
    GET = parse("GET"),
    HEAD = parse("HEAD"),
    OPTIONS = parse("OPTIONS"),
    TRACE = parse("TRACE"),
    DELETE = parse("DELETE"),
    PUT = parse("PUT"),
    POST = parse("POST"),
    PATCH = parse("PATCH"),
    CONNECT = parse("CONNECT"),
    _,

    pub fn parse(method: []const u8) MethodType {
        var x: MethodType = 0;
        const len = @min(method.len, MAX_METHOD_SIZE);
        @memcpy(std.mem.asBytes(&x)[0..len], method[0..len]);
        return x;
    }

    pub fn write(self: Method, writer: anytype) !void {
        const bytes = std.mem.asBytes(&@intFromEnum(self));
        const slice = std.mem.sliceTo(bytes, 0);
        try writer.writeAll(slice);
    }
};
