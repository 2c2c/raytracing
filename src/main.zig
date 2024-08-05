const std = @import("std");
const color = @import("color.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

pub fn main() !void {
    const image_width = 256;
    const image_height = 256;

    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        try stderr.print("Scanlines remaining {}\n", .{image_height - j});
        for (0..image_width) |i| {
            const r: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(image_width - 1));
            const g: f32 = @as(f32, @floatFromInt(j)) / @as(f32, @floatFromInt(image_height - 1));
            const b: f32 = 0.0;
            const pixel_color = color.Color.init(r, g, b);
            try color.write_color(stdout, pixel_color);
        }
    }

    try stderr.print("DOne\n", .{});
}
