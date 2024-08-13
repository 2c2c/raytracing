const std = @import("std");
const color = @import("color.zig");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");
const hittable = @import("hittable.zig");
const hittable_list = @import("hittable_list.zig");
const sphere = @import("sphere.zig");
const interval = @import("interval.zig");
const camera = @import("camera.zig");
const material = @import("material.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

var xoshiro = std.rand.DefaultPrng.init(0);
const random = xoshiro.random();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var w = hittable_list.HittableList.empty(alloc);
    const world = w._hittable();

    var a: i32 = -1;
    while (a < 5) : (a += 1) {
        var b: i32 = -1;
        while (b < 5) : (b += 1) {
            const choose_mat = random.float(f32);
            const center = vec3.Point3.init(@as(f32, @floatFromInt(a)) + 0.9 * random.float(f32), 0.2, @as(f32, @floatFromInt(b)) + 0.9 * random.float(f32));

            if ((center.sub(vec3.Point3.init(4, 0.2, 0)).len() > 0.9)) {
                try stderr.print("{d:.3} {d:.3} {d:.3} choose_mat = {d:.3}\n", .{
                    center.x(),
                    center.y(),
                    center.z(),
                    choose_mat,
                });

                if (choose_mat < 1.0) {
                    const albedo = color.Color.rand();
                    var lamb_mat = try alloc.create(material.Lambertian);
                    lamb_mat.* = material.Lambertian{
                        .albedo = albedo,
                    };
                    const mat = try alloc.create(material.Material);
                    mat.* = lamb_mat._material();
                    var random_sphere = try alloc.create(sphere.Sphere);
                    random_sphere.* = sphere.Sphere{
                        // .center = vec3.Point3.init(a, b, 0),
                        .center = vec3.Point3.init(@as(f32, @floatFromInt(a)), @as(f32, @floatFromInt(b)), 0),
                        .radius = 0.2,
                        .mat = mat.*,
                    };
                    const s = random_sphere._hittable();
                    try w.add(s);
                } else if (choose_mat < 0.95) {
                    const albedo = color.Color.rand_range(0.5, 1.0);
                    const fuzz = random.float(f32) * 0.5;
                    var metal_mat = try alloc.create(material.Metal);
                    metal_mat.* = material.Metal{
                        .albedo = albedo,
                        .fuzz = fuzz,
                    };
                    const mat = try alloc.create(material.Material);
                    mat.* = metal_mat._material();
                    var random_sphere = try alloc.create(sphere.Sphere);
                    random_sphere.* = sphere.Sphere{
                        // .center = vec3.Point3.init(a, b, 0),
                        .center = vec3.Point3.init(@as(f32, @floatFromInt(a)), @as(f32, @floatFromInt(b)), 0),
                        .radius = 0.2,
                        .mat = mat.*,
                    };
                    const s = random_sphere._hittable();
                    try w.add(s);
                } else {
                    var dialectric_mat = try alloc.create(material.Dialectric);
                    dialectric_mat.* = material.Dialectric{
                        .refraction_index = 1.5,
                    };
                    const mat = try alloc.create(material.Material);
                    mat.* = dialectric_mat._material();
                    var random_sphere = try alloc.create(sphere.Sphere);
                    random_sphere.* = sphere.Sphere{
                        // .center = vec3.Point3.init(a, b, 0),
                        .center = vec3.Point3.init(@as(f32, @floatFromInt(a)), @as(f32, @floatFromInt(b)), 0),
                        .radius = 0.2,
                        .mat = mat.*,
                    };
                    const s = random_sphere._hittable();
                    try w.add(s);
                }
            }
        }
    }
    for (w.objects.items) |*item| {
        const s: *sphere.Sphere = @alignCast(@ptrCast(item));
        try stderr.print("center {d:.3} {d:.3} {d:.3} radius {}\n", .{
            s.*.center.x(),
            s.*.center.y(),
            s.*.center.z(),
            s.*.radius,
        });
    }

    try stderr.print("world size: {}\n", .{w.objects.items.len});

    var cam = camera.Camera{};
    cam.aspect_ratio = 16.0 / 9.0;
    cam.img_width = 1200;
    cam.samples_per_pixel = 500;
    cam.max_depth = 50;

    cam.vfov = 20;
    cam.lookfrom = vec3.Point3.init(13, 2, 3);
    cam.lookat = vec3.Point3.init(0, 0, 0);
    cam.vup = vec3.Vec3.init(0, 1, 0);

    cam.defocus_angle = 0.6;
    cam.focus_dist = 10.0;

    try cam.render(&world);
}
