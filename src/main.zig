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

    // var material_ground = material.Lambertian{
    //     .albedo = color.Color.init(0.5, 0.5, 0.5),
    // };
    //
    // var ground_sphere = try alloc.create(sphere.Sphere);
    // defer alloc.destroy(ground_sphere);
    // ground_sphere.* = sphere.Sphere{
    //     .center = vec3.Point3.init(0, -1000, 0),
    //     .radius = 1000,
    //     .mat = material_ground._material(),
    // };
    // var gs = ground_sphere._hittable();
    // try w.add(&gs);

    var a: i32 = -1;
    while (a < 5) : (a += 1) {
        var b: i32 = -1;
        while (b < 5) : (b += 1) {
            const choose_mat = random.float(f32);
            const center = vec3.Point3.init(@as(f32, @floatFromInt(a)) + 0.9 * random.float(f32), 0.2, @as(f32, @floatFromInt(b)) + 0.9 * random.float(f32));

            if ((center.sub(vec3.Point3.init(4, 0.2, 0)).len() > 0.9)) {
                var mat: material.Material = undefined;

                try stderr.print("{d:.3} {d:.3} {d:.3} choose_mat = {d:.3}\n", .{
                    center.x(),
                    center.y(),
                    center.z(),
                    choose_mat,
                });

                if (choose_mat < 1.0) {
                    const albedo = color.Color.rand();
                    var lamb_mat = material.Lambertian{
                        .albedo = albedo,
                    };
                    mat = lamb_mat._material();
                } else if (choose_mat < 0.95) {
                    const albedo = color.Color.rand_range(0.5, 1.0);
                    const fuzz = random.float(f32) * 0.5;
                    var metal_mat = material.Metal{
                        .albedo = albedo,
                        .fuzz = fuzz,
                    };
                    mat = metal_mat._material();
                } else {
                    var dialectric_mat = material.Dialectric{
                        .refraction_index = 1.5,
                    };
                    mat = dialectric_mat._material();
                }
                var random_sphere = sphere.Sphere{
                    .center = center,
                    .radius = 0.2,
                    .mat = mat,
                };
                const s = random_sphere._hittable();
                try stderr.print("sphere: {any}\n", .{random_sphere});
                try w.add(s);
            }
        }
    }

    try stderr.print("world size: {}\n", .{w.objects.items.len});

    var material1 = material.Dialectric{
        .refraction_index = 1.5,
    };
    var sphere1 = sphere.Sphere{
        .center = vec3.Point3.init(0, 1, 0),
        .radius = 1.0,
        .mat = material1._material(),
    };
    const s1 = sphere1._hittable();
    try w.add(s1);

    var material2 = material.Lambertian{
        .albedo = color.Color.init(0.4, 0.2, 0.1),
    };
    var sphere2 = sphere.Sphere{
        .center = vec3.Point3.init(-4, 1, 0),
        .radius = 1.0,
        .mat = material2._material(),
    };
    const s2 = sphere2._hittable();
    try w.add(s2);

    var material3 = material.Metal{
        .albedo = color.Color.init(0.7, 0.6, 0.5),
        .fuzz = 0.5,
    };
    var sphere3 = sphere.Sphere{
        .center = vec3.Point3.init(4, 1, 0),
        .radius = 1.0,
        .mat = material3._material(),
    };
    const s3 = sphere3._hittable();
    try w.add(s3);

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
