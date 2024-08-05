const std = @import("std");
const vec3 = @import("vec3.zig");

pub const Color = vec3.Vec3;

pub fn write_color(out: std.fs.File.Writer, pixel_color: Color) !void {
    const r = pixel_color.x();
    const g = pixel_color.y();
    const b = pixel_color.z();

    // Write the translated [0,255] value of each color component.
    const ir: u8 = @intFromFloat(255.999 * r);
    const ig: u8 = @intFromFloat(255.999 * g);
    const ib: u8 = @intFromFloat(255.999 * b);

    try out.print("{d} {d} {d}\n", .{ ir, ig, ib });
}
