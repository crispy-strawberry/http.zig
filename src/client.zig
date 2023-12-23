const std = @import("std");
const net = std.net;

const Allocator = std.mem.Allocator;

/// An HTTP/1.1 compliant client
pub const Client = @This();

allocator: Allocator,

pub fn init(allocator: Allocator) Client {
    return Client{
        .allocator = allocator,
    };
}
