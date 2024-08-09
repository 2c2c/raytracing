const std = @import("std");
const vec3 = @import("vec3.zig");
const interval = @import("interval.zig");

pub const Color = vec3.Vec3;

pub fn write_color(out: std.fs.File.Writer, pixel_color: Color) !void {
    var r = pixel_color.x();
    var g = pixel_color.y();
    var b = pixel_color.z();

    r = linear_to_gamma(r);
    g = linear_to_gamma(g);
    b = linear_to_gamma(b);

    const intensity = interval.Interval.init(0.000, 0.999);
    const ir: u8 = @intFromFloat(256 * intensity.clamp(r));
    const ig: u8 = @intFromFloat(256 * intensity.clamp(g));
    const ib: u8 = @intFromFloat(256 * intensity.clamp(b));

    try out.print("{d} {d} {d}\n", .{ ir, ig, ib });
}

pub fn linear_to_gamma(linear_component: f32) f32 {
    if (linear_component > 0) {
        return @sqrt(linear_component);
    }

    return 0;
}
