const std = @import("std");
const color = @import("color.zig");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

pub fn ray_color(r: ray.Ray) color.Color {
    const unit_direction = r.direction.unit_vector();
    const a = (unit_direction.y() + 1.0) * 0.5;
    const start = color.Color.init(1.0, 1.0, 1.0).scalar_mul(1.0 - a);
    const end = color.Color.init(0.5, 0.7, 1.0).scalar_mul(a);
    return start.add(end);
}

pub fn main() !void {
    const aspect_ratio = 16.0 / 9.0;
    const img_width: u32 = 400;

    // var img_height: f32 = @intFromFloat(@as(f32, @floatFromInt(img_width)) / aspect_ratio);
    var img_height: u32 = @intFromFloat(@as(f32, @floatFromInt(img_width)) / aspect_ratio);
    img_height = if (img_height < 1) 1 else img_height;

    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * @as(f32, @floatFromInt(img_width)) / @as(f32, @floatFromInt(img_height));
    // const camera_center = vec3.point3(0.0, 0.0, 0.0);
    const camera_center = vec3.Point3.init(0, 0, 0);
    const viewport_u = vec3.Vec3.init(viewport_width, 0.0, 0.0);
    const viewport_v = vec3.Vec3.init(0.0, -viewport_height, 0.0);

    const pixel_delta_u = viewport_u.scalar_div(img_width);
    const pixel_delta_v = viewport_v.scalar_div(@floatFromInt(img_height));

    const viewport_upper_left = camera_center.sub(vec3.Vec3.init(0, 0, focal_length)).sub(viewport_u.scalar_div(2)).sub(viewport_v.scalar_div(2));
    const pixel_00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).scalar_mul(0.5));
    try stdout.print("P3\n{} {}\n255\n", .{ img_width, img_height });

    for (0..img_height) |j| {
        try stderr.print("Scanlines remaining {}\n", .{img_height - j});
        for (0..img_width) |i| {
            const pixel_center = pixel_00_loc.add(pixel_delta_u.scalar_mul(@floatFromInt(i))).add(pixel_delta_v.scalar_mul(@floatFromInt(j)));
            const ray_direction = pixel_center.sub(camera_center);
            const r = ray.Ray.init(camera_center, ray_direction);

            const pixel_color = ray_color(r);
            try color.write_color(stdout, pixel_color);
        }
    }

    try stderr.print("Done\n", .{});
}

pub fn ray_scene() !void {
    const aspect_ratio = 16.0 / 9.0;
    const img_width = 400;

    const img_height: f32 = @intFromFloat(@as(f32, @floatFromInt(img_width)) / aspect_ratio);

    const viewport_height = 2.0;
    const viewport_width = viewport_height * @as(f32, @floatFromInt(img_width)) / img_height;
    _ = viewport_width; // autofix
}
