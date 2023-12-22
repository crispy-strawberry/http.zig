const std = @import("std");
const Server = @import("server.zig");

const Headers = @import("headers.zig").Headers;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    var headers = Headers.init(allocator);
    defer headers.deinit();

    try headers.set("Content-Length", "60");
    try headers.set("Content-Type", "text/html; charset=UTF-8");
    try headers.set("Date", "Thursday, 21 December 2023");

    std.debug.print("\nContent-Length is: {?}\n", .{headers.getContentLength()});
    std.debug.print("\nDate is: {?s}\n", .{headers.get("Date")});

    var server = Server.init(allocator, .{
        .reuse_port = true,
    });
    defer server.deinit();

    const address = std.net.Address.initIp4([_]u8{ 127, 0, 0, 1 }, 8000);
    try server.listen(address);

    while (true) {
        try server.accept();
    }
}
