const std = @import("std");
var xoshiro = std.rand.DefaultPrng.init(0);
const random = xoshiro.random();

pub const Vec3 = struct {
    e: [3]f32,

    pub fn init(e1: f32, e2: f32, e3: f32) Vec3 {
        const e: [3]f32 = .{ e1, e2, e3 };
        return Vec3{ .e = e };
    }

    pub fn x(self: *const Vec3) f32 {
        return self.e[0];
    }

    pub fn y(self: *const Vec3) f32 {
        return self.e[1];
    }

    pub fn z(self: *const Vec3) f32 {
        return self.e[2];
    }

    pub fn neg(self: *const Vec3) Vec3 {
        const e = .{
            -self.e[0],
            -self.e[1],
            -self.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn add(self: *const Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[0] + other.e[0],
            self.e[1] + other.e[1],
            self.e[2] + other.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn sub(self: *const Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[0] - other.e[0],
            self.e[1] - other.e[1],
            self.e[2] - other.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn mul(self: *const Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[0] * other.e[0],
            self.e[1] * other.e[1],
            self.e[2] * other.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn div(self: *const Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[0] / other.e[0],
            self.e[1] / other.e[1],
            self.e[2] / other.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn len(self: *const Vec3) f32 {
        return @sqrt(self.len_squared());
    }

    pub fn len_squared(self: *const Vec3) f32 {
        return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
    }

    pub fn scalar_add(self: *const Vec3, t: f32) Vec3 {
        const e = .{
            self.e[0] + t,
            self.e[1] + t,
            self.e[2] + t,
        };
        return Vec3{ .e = e };
    }

    pub fn scalar_sub(self: *const Vec3, t: f32) Vec3 {
        const e = .{
            self.e[0] - t,
            self.e[1] - t,
            self.e[2] - t,
        };
        return Vec3{ .e = e };
    }

    pub fn scalar_mul(self: *const Vec3, t: f32) Vec3 {
        const e = .{
            self.e[0] * t,
            self.e[1] * t,
            self.e[2] * t,
        };
        return Vec3{ .e = e };
    }

    pub fn scalar_div(self: *const Vec3, t: f32) Vec3 {
        const e = .{
            self.e[0] / t,
            self.e[1] / t,
            self.e[2] / t,
        };
        return Vec3{ .e = e };
    }

    pub fn dot(self: *const Vec3, other: Vec3) f32 {
        return self.e[0] * other.e[0] + self.e[1] * other.e[1] + self.e[2] * other.e[2];
    }

    pub fn cross(self: *const Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[1] * other.e[2] - self.e[2] * other.e[1],
            self.e[2] * other.e[0] - self.e[0] * other.e[2],
            self.e[0] * other.e[1] - self.e[1] * other.e[0],
        };
        return Vec3{ .e = e };
    }

    pub fn unit_vector(v: *const Vec3) Vec3 {
        return v.scalar_div(v.len());
    }

    pub fn random_in_unit_sphere() Vec3 {
        while (true) {
            const p = Vec3.rand_range(-1.0, 1.0);
            if (p.len_squared() < 1) {
                return p;
            }
        }
    }

    pub fn random_unit_vector() Vec3 {
        const rius = random_in_unit_sphere();
        return rius.unit_vector();
    }

    pub fn random_on_hemisphere(normal: Vec3) Vec3 {
        const on_unit_sphere = random_unit_vector();
        if (on_unit_sphere.dot(normal) > 0.0) {
            return on_unit_sphere;
        }

        return on_unit_sphere.neg();
    }

    pub fn reflect(v: Vec3, norm: Vec3) Vec3 {
        return v.sub(norm.scalar_mul(2 * v.dot(norm)));
    }

    pub fn refract(uv: Vec3, n: Vec3, etai_over_etat: f32) Vec3 {
        const cos_theta = @min(n.dot(uv.neg()), 1.0);
        const r_out_perp = n.scalar_mul(cos_theta).add(uv).scalar_mul(etai_over_etat);
        // const r_out_perp = cos_theta.mul(n).add(uv).mul(etai_over_etat);
        const r_out_parallel = n.scalar_mul(-@sqrt(@abs(1.0 - r_out_perp.len_squared())));

        return r_out_perp.add(r_out_parallel);
    }

    pub fn rand() Vec3 {
        const rand1 = random.float(f32);
        const rand2 = random.float(f32);
        const rand3 = random.float(f32);

        return Vec3.init(rand1, rand2, rand3);
    }

    pub fn rand_range(min: f32, max: f32) Vec3 {
        const rand1 = min + random.float(f32) * (max - min);
        const rand2 = min + random.float(f32) * (max - min);
        const rand3 = min + random.float(f32) * (max - min);

        return Vec3.init(rand1, rand2, rand3);
    }

    pub fn near_zero(self: *const Vec3) bool {
        const s = 1e-8;
        return @abs(self.e[0]) < s and @abs(self.e[1]) < s and @abs(self.e[2]) < s;
    }
};

pub const Point3 = Vec3;
