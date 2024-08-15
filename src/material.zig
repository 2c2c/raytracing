const std = @import("std");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const color = @import("color.zig");
const vec3 = @import("vec3.zig");

var xoshiro = std.rand.DefaultPrng.init(0);
const random = xoshiro.random();

pub const Material = struct {
    ctx: *anyopaque,
    vtable: *const VTable,

    const VTable = struct {
        scatter: *const fn (
            ctx: *anyopaque,
            r_in: *const ray.Ray,
            hit_record: *const hittable.HitRecord,
            attenuation: *color.Color,
            scattered: *ray.Ray,
        ) bool,
    };

    pub fn scatter(
        material: Material,
        r_in: *const ray.Ray,
        hit_record: *const hittable.HitRecord,
        attenuation: *color.Color,
        scattered: *ray.Ray,
    ) bool {
        return material.vtable.scatter(material.ctx, r_in, hit_record, attenuation, scattered);
    }
};

pub const Lambertian = struct {
    albedo: color.Color,

    const vtable = Material.VTable{
        .scatter = &scatter,
    };

    pub fn _material(lambertian: *Lambertian) Material {
        return Material{
            .ctx = @ptrCast(lambertian),
            .vtable = &vtable,
        };
    }

    pub fn scatter(
        ctx: *anyopaque,
        r_in: *const ray.Ray,
        hit_record: *const hittable.HitRecord,
        attenuation: *color.Color,
        scattered: *ray.Ray,
    ) bool {
        _ = r_in; // autofix
        // todo
        const self: *Lambertian = @alignCast(@ptrCast(ctx));
        var scatter_direction = hit_record.normal.add(vec3.Vec3.random_unit_vector());
        scattered.* = ray.Ray.init(hit_record.p, scatter_direction);
        attenuation.* = self.albedo;

        if (scatter_direction.near_zero()) {
            scatter_direction = hit_record.normal;
        }

        return true;
    }
};

pub const Metal = struct {
    albedo: color.Color,
    fuzz: f64,

    pub fn init(albedo: color.Color, fuzz: f64) Metal {
        return Metal{
            .albedo = albedo,
            .fuzz = if (fuzz < 1.0) fuzz else 1.0,
        };
    }

    const vtable = Material.VTable{
        .scatter = &scatter,
    };

    pub fn _material(metal: *Metal) Material {
        return Material{
            .ctx = @ptrCast(metal),
            .vtable = &vtable,
        };
    }

    pub fn scatter(
        ctx: *anyopaque,
        r_in: *const ray.Ray,
        hit_record: *const hittable.HitRecord,
        attenuation: *color.Color,
        scattered: *ray.Ray,
    ) bool {
        const self: *Metal = @alignCast(@ptrCast(ctx));
        var reflected = vec3.Vec3.reflect(r_in.direction, hit_record.normal);
        reflected = reflected.unit_vector().add(vec3.Vec3.random_unit_vector().scalar_mul(self.fuzz));

        scattered.* = ray.Ray.init(hit_record.p, reflected);
        attenuation.* = self.albedo;

        return (scattered.direction.dot(hit_record.normal) > 0.0);
    }
};

pub const Dialectric = struct {
    refraction_index: f64,

    const vtable = Material.VTable{
        .scatter = &scatter,
    };

    pub fn _material(dialectric: *Dialectric) Material {
        return Material{
            .ctx = @ptrCast(dialectric),
            .vtable = &vtable,
        };
    }

    pub fn scatter(
        ctx: *anyopaque,
        r_in: *const ray.Ray,
        hit_record: *const hittable.HitRecord,
        attenuation: *color.Color,
        scattered: *ray.Ray,
    ) bool {
        const self: *Dialectric = @alignCast(@ptrCast(ctx));
        attenuation.* = color.Color.init(1, 1, 1);
        const ri = if (hit_record.front_face) 1.0 / self.refraction_index else self.refraction_index;

        const unit_direction = r_in.direction.unit_vector();

        const cos_theta = @min(unit_direction.neg().dot(hit_record.normal), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);
        const cannot_refract = ri * sin_theta > 1.0;

        var direction: vec3.Vec3 = undefined;
        if (cannot_refract or reflectance(cos_theta, ri) > random.float(f64)) {
            direction = vec3.Vec3.reflect(unit_direction, hit_record.normal);
        } else {
            direction = vec3.Vec3.refract(unit_direction, hit_record.normal, ri);
        }

        scattered.* = ray.Ray.init(hit_record.p, direction);
        return true;
    }

    pub fn reflectance(cosine: f64, refraction_index: f64) f64 {
        var r0 = (1 - refraction_index) / (1 + refraction_index);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f64, 1 - cosine, 5);
    }
};
