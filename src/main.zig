const std = @import("std");
const Server = @import("server.zig");

pub fn main() !void {
    var server = Server.init(.{
        .reuse_port = true,
    });
    defer server.deinit();

    const address = std.net.Address.initIp4([_]u8{ 127, 0, 0, 1 }, 7500);
    try server.listen(address);

    while (true) {
        try server.accept();
    }
}
