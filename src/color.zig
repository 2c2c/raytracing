const std = @import("std");
const vec3 = @import("vec3.zig");
const interval = @import("interval.zig");

pub const Color = vec3.Vec3;

pub fn write_color(out: std.fs.File.Writer, pixel_color: Color) !void {
    const r = pixel_color.x();
    const g = pixel_color.y();
    const b = pixel_color.z();

    const intensity = interval.Interval.init(0.000, 0.999);
    const ir: u8 = @intFromFloat(256 * intensity.clamp(r));
    const ig: u8 = @intFromFloat(256 * intensity.clamp(g));
    const ib: u8 = @intFromFloat(256 * intensity.clamp(b));

    try out.print("{d} {d} {d}\n", .{ ir, ig, ib });
}
