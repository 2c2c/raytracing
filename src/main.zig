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

    var material_ground = try alloc.create(material.Lambertian);
    material_ground.* = material.Lambertian{
        .albedo = color.Color.init(0.6, 0.6, 0.6),
    };
    const mg = material_ground._material();
    var ground_sphere = try alloc.create(sphere.Sphere);
    // defer alloc.destroy(ground_sphere);
    ground_sphere.* = sphere.Sphere{
        .center = vec3.Point3.init(0, -1000, 0),
        .radius = 1000,
        .mat = mg,
    };
    const gs = ground_sphere._hittable();
    try w.add(gs);

    var a: i32 = -11;
    while (a < 11) : (a += 1) {
        var b: i32 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = random.float(f64);
            const center = vec3.Point3.init(@as(f64, @floatFromInt(a)) + 0.9 * random.float(f64), 0.2, @as(f64, @floatFromInt(b)) + 0.9 * random.float(f64));

            if ((center.sub(vec3.Point3.init(4, 0.2, 0)).len() > 0.9)) {
                var random_sphere = try alloc.create(sphere.Sphere);
                if (choose_mat < 0.8) {
                    var lamb_mat = try alloc.create(material.Lambertian);

                    const albedo = color.Color.rand();
                    lamb_mat.* = material.Lambertian{
                        .albedo = albedo,
                    };
                    const mat = lamb_mat._material();
                    random_sphere.* = sphere.Sphere{
                        .center = center,
                        .radius = 0.2,
                        .mat = mat,
                    };
                    const s = random_sphere._hittable();
                    try w.add(s);
                } else if (choose_mat < 0.95) {
                    var metal_mat = try alloc.create(material.Metal);

                    const albedo = color.Color.rand_range(0.5, 1.0);
                    const fuzz = random.float(f64) * 0.5;
                    metal_mat.* = material.Metal{
                        .albedo = albedo,
                        .fuzz = fuzz,
                    };
                    const mat = metal_mat._material();
                    random_sphere.* = sphere.Sphere{
                        .center = center,
                        .radius = 0.2,
                        .mat = mat,
                    };
                    const s = random_sphere._hittable();
                    try w.add(s);
                } else {
                    var dialectric_mat = try alloc.create(material.Dialectric);

                    dialectric_mat.* = material.Dialectric{
                        .refraction_index = 1.5,
                    };
                    const mat = dialectric_mat._material();
                    random_sphere.* = sphere.Sphere{
                        .center = center,
                        .radius = 0.2,
                        .mat = mat,
                    };
                    const s = random_sphere._hittable();
                    try w.add(s);
                }
            }
        }
    }

    var material1 = try alloc.create(material.Dialectric);
    material1.* = material.Dialectric{
        .refraction_index = 1.5,
    };
    const m1 = material1._material();
    var sphere1 = try alloc.create(sphere.Sphere);
    sphere1.* = sphere.Sphere{
        .center = vec3.Point3.init(0, 1, 0),
        .radius = 1.0,
        .mat = m1,
    };
    const s1 = sphere1._hittable();
    try w.add(s1);

    var material2 = try alloc.create(material.Lambertian);
    material2.* = material.Lambertian{
        .albedo = color.Color.init(0.2, 0.7, 0.7),
    };
    const m2 = material2._material();
    var sphere2 = try alloc.create(sphere.Sphere);
    sphere2.* = sphere.Sphere{
        .center = vec3.Point3.init(-4, 1, 0),
        .radius = 1.0,
        .mat = m2,
    };
    const s2 = sphere2._hittable();
    try w.add(s2);

    var material3 = try alloc.create(material.Metal);
    material3.* = material.Metal{
        .albedo = color.Color.init(0.8, 0.8, 0.7),
        .fuzz = 0.02,
    };
    const m3 = material3._material();
    var sphere3 = try alloc.create(sphere.Sphere);
    sphere3.* = sphere.Sphere{
        .center = vec3.Point3.init(4, 1, 0),
        .radius = 1.0,
        .mat = m3,
    };
    const s3 = sphere3._hittable();
    try w.add(s3);

    defer {
        for (w.objects.items) |item| {
            const s: *sphere.Sphere = @alignCast(@ptrCast(item.ctx));
            stderr.print("deleting {}\n", .{s}) catch unreachable;
            if (s.mat.vtable == &material.Lambertian.vtable) {
                const mat: *material.Lambertian = @alignCast(@ptrCast(s.mat.ctx));
                alloc.destroy(mat);
            } else if (s.mat.vtable == &material.Metal.vtable) {
                const mat: *material.Metal = @alignCast(@ptrCast(s.mat.ctx));
                alloc.destroy(mat);
            } else if (s.mat.vtable == &material.Dialectric.vtable) {
                const mat: *material.Dialectric = @alignCast(@ptrCast(s.mat.ctx));
                alloc.destroy(mat);
            }
            alloc.destroy(s);
        }
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
