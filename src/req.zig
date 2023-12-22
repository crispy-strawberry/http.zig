const std = @import("std");
const net = std.net;

const Headers = @import("headers.zig").Headers;

const StreamServer = net.StreamServer;

/// A request object
/// The request takes requests in this formes in this
/// form.
pub const Request = struct {
    stream: net.Stream,
    address: net.Address,
    headers: Headers,

    pub fn new(conn: StreamServer.Connection) Request {
        return Request{
            .stream = conn.stream,
            .address = conn.address,
        };
    }

    pub fn close(self: *Request) void {
        self.conn.stream.close();
    }

    pub fn write(self: *Request, bytes: []const u8) !usize {
        return try self.stream.write(bytes);
    }

    pub fn writeAll(self: *Request, bytes: []const u8) !void {
        try self.conn.stream.writeAll(bytes);
    }
};
