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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var w = hittable_list.HittableList.empty(alloc);
    const world = w._hittable();

    var material_ground = material.Lambertian{
        .albedo = color.Color.init(0.8, 0.8, 0.0),
    };

    var material_center = material.Lambertian{
        .albedo = color.Color.init(0.1, 0.2, 0.5),
    };

    var material_left = material.Metal.init(
        color.Color.init(0.8, 0.8, 0.8),
        0.3,
    );

    var material_right = material.Metal.init(
        color.Color.init(0.8, 0.6, 0.2),
        0.0,
    );

    var ground_sphere = try alloc.create(sphere.Sphere);
    defer alloc.destroy(ground_sphere);
    ground_sphere.* = sphere.Sphere{
        .center = vec3.Point3.init(0, -100.5, -1),
        .radius = 100,
        .mat = material_ground._material(),
    };
    var gs = ground_sphere._hittable();

    var center_sphere = try alloc.create(sphere.Sphere);
    defer alloc.destroy(center_sphere);
    center_sphere.* = sphere.Sphere{
        .center = vec3.Point3.init(0, 0, -1.2),
        .radius = 0.5,
        .mat = material_center._material(),
    };
    var cs = center_sphere._hittable();

    var left_sphere = try alloc.create(sphere.Sphere);
    defer alloc.destroy(left_sphere);
    left_sphere.* = sphere.Sphere{
        .center = vec3.Point3.init(-1, 0, -1),
        .radius = 0.5,
        .mat = material_left._material(),
    };
    var ls = left_sphere._hittable();

    var right_sphere = try alloc.create(sphere.Sphere);
    defer alloc.destroy(right_sphere);
    right_sphere.* = sphere.Sphere{
        .center = vec3.Point3.init(1, 0, -1),
        .radius = 0.5,
        .mat = material_right._material(),
    };
    var rs = right_sphere._hittable();

    try w.add(&gs);
    try w.add(&cs);
    try w.add(&ls);
    try w.add(&rs);

    var cam = camera.Camera{};
    cam.aspect_ratio = 16.0 / 9.0;
    cam.img_width = 400;
    cam.samples_per_pixel = 100;
    cam.max_depth = 50;
    try cam.render(&world);
}
