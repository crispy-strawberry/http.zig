const std = @import("std");
const net = std.net;

const StreamServer = net.StreamServer;
const Address = net.Address;

/// An HTTP/1.1 compliant web server
pub const Server = @This();

stream: StreamServer,

/// Initializes a `Server`. It takes `StreamServer.Options`
/// Use `deinit` to deinitialize the `Server`.
pub fn init(options: StreamServer.Options) Server {
    return Server{ .stream = StreamServer.init(options) };
}

pub fn listen(self: *Server, addr: Address) !void {
    try self.stream.listen(addr);
}

pub fn close(self: *Server) void {
    self.stream.close();
}

pub fn deinit(self: *Server) void {
    self.stream.deinit();
}

pub fn accept(self: *Server) !void {
    var conn = try self.stream.accept();
    defer conn.stream.close();

    try conn.stream.writeAll(
        \\HTTP/1.1 200 OK
        \\
    );
}
