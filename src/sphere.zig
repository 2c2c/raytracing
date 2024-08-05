const std = @import("std");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");

pub const Sphere = struct {
    center: vec3.Point3,
    radius: f32,

    pub const vtable = hittable.Hittable.VTable{
        .hit = &hit,
    };

    pub fn _hittable(sphere: *Sphere) hittable.Hittable {
        return .{
            .ctx = @ptrCast(sphere),
            .vtable = &vtable,
        };
    }

    pub fn hit(ctx: *anyopaque, r: *ray.Ray, ray_tmin: f32, ray_tmax: f32, rec: *hittable.HitRecord) bool {
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
        if (root <= ray_tmin or ray_tmax <= root) {
            root = (h + sqrtd) / a;
            if (root <= ray_tmin or ray_tmax <= root) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.sub(self.center).scalar_div(self.radius);
        rec.set_face_normal(r.*, outward_normal);

        return true;
    }
};
