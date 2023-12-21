const std = @import("std");
const net = std.net;

/// The size of the request buffer. This can be changed at
/// compile time using the `-Dreq_size=<size in bytes>` flag.
const REQ_SIZE: usize = @import("config").REQ_SIZE;

const StreamServer = net.StreamServer;
const Address = net.Address;

/// An HTTP/1.1 compliant web server
pub const Server = @This();

stream: StreamServer,

/// Initializes a `Server`. It takes `StreamServer.Options`
/// Use `deinit` to deinitialize the `Server`.
pub fn init(options: StreamServer.Options) Server {
    if (@import("builtin").mode == .Debug)
        std.debug.print("The request buffer size is: {}\n", .{REQ_SIZE});

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

    var buf: [REQ_SIZE]u8 = undefined;
    const len = try conn.stream.read(buf[0..]);
    std.debug.print("The request size was: {}\n", .{len});
    std.debug.print("The request was: \n{s}\n", .{buf[0..len]});

    try conn.stream.writeAll(
        \\HTTP/1.1 200 OK
        \\Date: Mon, 23 May 2005 22:38:34 GMT
        \\Content-Type: text/html; charset=UTF-8
        \\Last-Modified: Wed, 08 Jan 2003 23:11:55 GMT
        \\Server: crispy/http.zig (Zig) (Microsoft/Windows)
        \\Accept-Ranges: bytes
        \\Connection: close
        \\
        \\<html>
        \\  <head>
        \\    <title>An Example Page</title>
        \\  </head>
        \\  <body>
        \\    <h1>My Web Server</h1>
        \\    <p>Hello World, this is a very simple HTML document.</p>
        \\  </body>
        \\</html>    
    );
}
