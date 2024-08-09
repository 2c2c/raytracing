const std = @import("std");
const color = @import("color.zig");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");
const hittable = @import("hittable.zig");
const hittable_list = @import("hittable_list.zig");
const sphere = @import("sphere.zig");
const interval = @import("interval.zig");
const camera = @import("camera.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var w = hittable_list.HittableList.empty(alloc);

    var sphere1 = try alloc.create(sphere.Sphere);
    defer alloc.destroy(sphere1);

    sphere1.* = sphere.Sphere{
        .center = vec3.Point3.init(0, 0, -1),
        .radius = 0.5,
    };
    var s1 = sphere1._hittable();

    var sphere2 = try alloc.create(sphere.Sphere);
    defer alloc.destroy(sphere2);

    sphere2.* = sphere.Sphere{
        .center = vec3.Point3.init(0, -100.5, -1),
        .radius = 100,
    };
    var s2 = sphere2._hittable();
    try w.add(&s1);
    try w.add(&s2);
    const world = w._hittable();

    var cam = camera.Camera{};
    cam.aspect_ratio = 16.0 / 9.0;
    cam.img_width = 400;
    try cam.render(&world);
}
