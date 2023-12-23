//! The http package provides a cross platform
//! HTTP/1.1 compliant client and server.

pub const Headers = @import("headers.zig").Headers;

pub const Method = @import("methods.zig").Method;

pub const Request = @import("req.zig").Request;

// I can do `pub const Server = @import("server.zig")` but
// it currently doesn't work well with ZLS
pub const Server = @import("server.zig");

pub const Client = @import("client.zig").Client;
