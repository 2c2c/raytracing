const std = @import("std");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");
const interval = @import("interval.zig");
const material = @import("material.zig");

pub const HitRecord = struct {
    p: vec3.Point3,
    normal: vec3.Vec3,
    mat: *material.Material,
    t: f32,
    front_face: bool,

    pub fn set_face_normal(self: *HitRecord, r: ray.Ray, outward_normal: vec3.Vec3) void {
        const front_face = r.direction.dot(outward_normal) < 0;
        self.normal = if (front_face) outward_normal else outward_normal.neg();
    }
};

pub const Hittable = struct {
    ctx: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        hit: *const fn (ctx: *anyopaque, r: *const ray.Ray, ray_t: interval.Interval, rec: *HitRecord) bool,
    };

    pub fn hit(hittable: Hittable, r: *const ray.Ray, ray_t: interval.Interval, rec: *HitRecord) bool {
        return hittable.vtable.hit(hittable.ctx, r, ray_t, rec);
    }
};
