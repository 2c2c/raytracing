const std = @import("std");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const interval = @import("interval.zig");
const material = @import("material.zig");

pub const Sphere = struct {
    center: vec3.Point3,
    radius: f32,
    mat: *material.Material,

    const vtable = hittable.Hittable.VTable{
        .hit = &hit,
    };

    pub fn _hittable(sphere: *Sphere) hittable.Hittable {
        return .{
            .ctx = @ptrCast(sphere),
            .vtable = &vtable,
        };
    }

    pub fn init(center: vec3.Point3, radius: f32, mat: *material.Material) Sphere {
        return .{
            .center = center,
            .radius = @max(0, radius),
            .mat = mat,
        };
    }

    pub fn hit(ctx: *anyopaque, r: *const ray.Ray, ray_t: interval.Interval, rec: *hittable.HitRecord) bool {
        const self: *Sphere = @alignCast(@ptrCast(ctx));

        const oc = self.center.sub(r.origin);
        const a = r.direction.len_squared();
        const h = r.direction.dot(oc);
        const c = oc.len_squared() - self.radius * self.radius;

        const discriminant = h * h - a * c;
        if (discriminant < 0) {
            return false;
        }

        const sqrtd = @sqrt(discriminant);

        var root = (h - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (h + sqrtd) / a;
            if (!ray_t.surrounds(root)) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.sub(self.center).scalar_div(self.radius);
        rec.set_face_normal(r.*, outward_normal);
        // set mat?
        // might not be necessary
        rec.mat = self.mat;

        return true;
    }
};
