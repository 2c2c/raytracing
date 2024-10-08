const std = @import("std");
const vec3 = @import("vec3.zig");

pub const Ray = struct {
    origin: vec3.Point3,
    direction: vec3.Vec3,

    pub fn init(origin: vec3.Point3, direction: vec3.Vec3) Ray {
        return Ray{
            .origin = origin,
            .direction = direction,
        };
    }

    pub fn at(self: *const Ray, t: f64) vec3.Point3 {
        return self.origin.add(self.direction.scalar_mul(t));
    }
};
