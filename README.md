# http.zig
Creating an HTTP/1.1 compliant server in Zig.

# Using
Let's look at how to use the `http` package in your own project.

+ Run the following command inside your project root - 
  ```
  zig fetch git+https://github.com/crispy-strawberry/http.zig#main --save=http
  ```
+ Open `build.zig` add the following lines -
  ```zig
  const http = b.dependency("http", .{
    .target = target,
    .optimize = optimize,
  });

  exe.addModule("http", http.module("http"));
    
  ```
+ Enjoy!
  ```zig
  const std = @import("std");
  const http = @import("http");

  const Server = http.Server;

  pub fn main() !void {
    var server = Server.init(allocator, .{
      .reuse_port = true,
    });
    defer server.deinit();

    try server.listen(std.net.Address.initIp4([_]u8{ 127, 0, 0, 1 }, 8000));

    while (true) {
      try server.accept();
    }
  }
    
  ```

# License
The library is dual licensed under `MPL` or `APACHE-2.0`.
Choose at your own discretion.

# Contributing 
Please make pull requests to https://codeberg.org/crispy-strawberry/http.zig
