const std = @import("std");
const rtweekend = @import("rtweekend.zig");
const hittable = @import("hittable.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const interval = @import("interval.zig");
const vec3 = @import("vec3.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

pub const Camera = struct {
    aspect_ratio: f32 = 1.0,
    img_width: u32 = 100,

    img_height: u32 = undefined,
    center: vec3.Point3 = undefined,
    pixel_00_loc: vec3.Point3 = undefined,
    pixel_delta_u: vec3.Vec3 = undefined,
    pixel_delta_v: vec3.Vec3 = undefined,

    pub fn render(self: *Camera, world: *const hittable.Hittable) !void {
        self.init();
        try stdout.print("P3\n{} {}\n255\n", .{ self.img_width, self.img_height });

        for (0..self.img_height) |j| {
            try stderr.print("Scanlines remaining {}\n", .{self.img_height - j});
            for (0..self.img_width) |i| {
                const pixel_center = self.pixel_00_loc.add(self.pixel_delta_u.scalar_mul(@floatFromInt(i))).add(self.pixel_delta_v.scalar_mul(@floatFromInt(j)));
                const ray_direction = pixel_center.sub(self.center);
                var r = ray.Ray.init(self.center, ray_direction);

                const pixel_color = ray_color(&r, world);
                try color.write_color(stdout, pixel_color);
            }
        }

        try stderr.print("Done\n", .{});
    }

    fn init(self: *Camera) void {
        self.img_height = @intFromFloat(@as(f32, @floatFromInt(self.img_width)) / self.aspect_ratio);
        self.img_height = if (self.img_height < 1) 1 else self.img_height;

        self.center = vec3.Point3.init(0, 0, 0);

        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * @as(f32, @floatFromInt(self.img_width)) / @as(f32, @floatFromInt(self.img_height));

        const viewport_u = vec3.Vec3.init(viewport_width, 0, 0);
        const viewport_v = vec3.Vec3.init(0, -viewport_height, 0);

        self.pixel_delta_u = viewport_u.scalar_div(@as(f32, @floatFromInt(self.img_width)));
        self.pixel_delta_v = viewport_v.scalar_div(@as(f32, @floatFromInt(self.img_height)));

        const viewport_upper_left = self.center.sub(vec3.Vec3.init(0, 0, focal_length)).sub(viewport_u.scalar_div(2)).sub(viewport_v.scalar_div(2));
        self.pixel_00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).scalar_mul(0.5));
    }

    fn ray_color(r: *const ray.Ray, world: *const hittable.Hittable) color.Color {
        var rec: hittable.HitRecord = undefined;
        if (world.hit(r, interval.Interval.init(0, std.math.inf(f32)), &rec)) {
            return rec.normal.add(color.Color.init(1, 1, 1)).scalar_mul(0.5);
        }

        const unit_direction = r.direction.unit_vector();
        const a = 0.5 * (unit_direction.y() + 1.0);

        const left = color.Color.init(1, 1, 1).scalar_mul(1.0 - a);
        const right = color.Color.init(0.5, 0.7, 1.0).scalar_mul(a);

        return left.add(right);
    }
};
