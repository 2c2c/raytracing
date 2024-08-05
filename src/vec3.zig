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
};

pub const Point3 = Vec3;
