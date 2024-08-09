const std = @import("std");
const rtweekend = @import("rtweekend.zig");
const hittable = @import("hittable.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const interval = @import("interval.zig");
const vec3 = @import("vec3.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();
var xoshiro = std.rand.DefaultPrng.init(0);
const random = xoshiro.random();

pub const Camera = struct {
    aspect_ratio: f32 = 1.0,
    img_width: u32 = 100,
    samples_per_pixel: u32 = 10,
    pixel_samples_scale: f32 = 1.0,
    max_depth: u32 = 10,

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
                var pixel_color = color.Color.init(0, 0, 0);
                for (0..self.samples_per_pixel) |s| {
                    _ = s; // autofix
                    const r = self.get_ray(@intCast(i), @intCast(j));
                    pixel_color = pixel_color.add(ray_color(&r, self.max_depth, world));
                }
                try color.write_color(stdout, pixel_color.scalar_mul(self.pixel_samples_scale));
            }
        }

        try stderr.print("Done\n", .{});
    }

    fn init(self: *Camera) void {
        self.img_height = @intFromFloat(@as(f32, @floatFromInt(self.img_width)) / self.aspect_ratio);
        self.img_height = if (self.img_height < 1) 1 else self.img_height;

        self.pixel_samples_scale = 1.0 / @as(f32, @floatFromInt(self.samples_per_pixel));

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

    fn ray_color(r: *const ray.Ray, depth: u32, world: *const hittable.Hittable) color.Color {
        if (depth <= 0) {
            return color.Color.init(0, 0, 0);
        }

        var rec: hittable.HitRecord = undefined;
        if (world.hit(r, interval.Interval.init(0.001, std.math.inf(f32)), &rec)) {
            var scattered: ray.Ray = undefined;
            var attenuation: color.Color = undefined;

            if (rec.mat.scatter(r, &rec, &attenuation, &scattered)) {
                return attenuation.mul(ray_color(&scattered, depth - 1, world));
            }
            return color.Color.init(0, 0, 0);
        }

        const unit_direction = r.direction.unit_vector();
        const a = 0.5 * (unit_direction.y() + 1.0);

        const left = color.Color.init(1, 1, 1).scalar_mul(1.0 - a);
        const right = color.Color.init(0.5, 0.7, 1.0).scalar_mul(a);

        return left.add(right);
    }

    fn get_ray(self: *const Camera, i: u32, j: u32) ray.Ray {
        const offset = sample_square();

        const ii = self.pixel_delta_u.scalar_mul((@as(f32, @floatFromInt(i)) + offset.x()));
        const jj = self.pixel_delta_v.scalar_mul((@as(f32, @floatFromInt(j)) + offset.y()));
        const pixel_sample = self.pixel_00_loc.add(ii).add(jj);

        const ray_origin = self.center;
        const ray_direction = pixel_sample.sub(ray_origin);

        return ray.Ray.init(ray_origin, ray_direction);
    }

    fn sample_square() vec3.Vec3 {
        const rand1 = random.float(f32);
        const rand2 = random.float(f32);
        return vec3.Vec3.init(rand1 - 0.5, rand2 - 0.5, 0);
    }
};
