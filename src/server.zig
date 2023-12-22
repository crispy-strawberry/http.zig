const std = @import("std");
const net = std.net;

/// The size of the request buffer. This can be changed at
/// compile time using the `-Dreq_size=<size in bytes>` flag.
const REQ_SIZE: usize = @import("config").REQ_SIZE;

const StreamServer = net.StreamServer;
const Address = net.Address;
const BufferedWriter = std.io.BufferedWriter;

/// An HTTP/1.1 compliant web server
pub const Server = @This();

socket: StreamServer,
allocator: std.mem.Allocator,
/// Initializes a `Server`. It takes `StreamServer.Options`
/// Use `deinit` to deinitialize the `Server`.
pub fn init(allocator: std.mem.Allocator, options: StreamServer.Options) Server {
    if (@import("builtin").mode == .Debug)
        std.debug.print("The request buffer size is: {}\n", .{REQ_SIZE});

    return Server{ .allocator = allocator, .socket = StreamServer.init(options) };
}

pub fn listen(self: *Server, addr: Address) !void {
    try self.socket.listen(addr);
}

pub fn close(self: *Server) void {
    self.socket.close();
}

pub fn deinit(self: *Server) void {
    self.socket.deinit();
}

pub fn accept(self: *Server) !void {
    var conn = try self.socket.accept();
    defer conn.stream.close();

    var buf: [REQ_SIZE]u8 = undefined;
    const len = try conn.stream.read(buf[0..]);

    // Something weird is happening with FireFox.
    if (len == 0) return;

    std.debug.print("The request size was: {}\n", .{len});
    std.debug.print("The request was: \n{s}\n", .{buf[0..len]});

    // var buffered_writer = createBufferedWriter(2048, conn.stream.writer());
    // var unbuffered_writer = conn.stream.writer();
    var buffered_writer = std.io.bufferedWriter(conn.stream.writer());
    var stream_writer = buffered_writer.writer();

    try stream_writer.writeAll(
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
        \\    <h1>My Web Server 😀😀</h1>
        \\    <p>Hello World, this is a very simple HTML document.</p>
        \\  </body>
        \\</html>    
    );

    try buffered_writer.flush();
}

pub fn getRawSocket(self: *const Server) std.os.socket_t {
    return self.socket.sockfd;
}

fn createBufferedWriter(comptime s: usize, underlying_stream: anytype) BufferedWriter(s, @TypeOf(underlying_stream)) {
    return .{ .unbuffered_writer = underlying_stream };
}
