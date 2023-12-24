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

## Options provided by the library
The library provides two options to change the default settings.
1. Firstly, it provides `REQ_SIZE` to choose the max size of the request stored
   on the stack. Default is 4kb.
2. It also provides an option to choose the max size in bytes of the HTTP
   method. For example, `GET` is 3 bytes and `POST` is 4 bytes. The default
   maximum size for methods is 24 bytes.

To change these, you can do -
```zig
const http = b.dependency("http", .{
  .target = target,
  .optimize = optimize,
  .REQ_SIZE = @as(usize, 2048),
  .MAX_METHOD_SIZE = @as(u16, 32),
});
```

# License
The library is dual licensed under `MPL` or `APACHE-2.0`.
Choose at your own discretion.

# Contributing 
Please make pull requests to https://codeberg.org/crispy-strawberry/http.zig
