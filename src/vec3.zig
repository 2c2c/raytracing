pub const Vec3 = struct {
    e: [3]f32,

    pub fn init(e1: f32, e2: f32, e3: f32) Vec3 {
        const e: [3]f32 = .{ e1, e2, e3 };
        return Vec3{ .e = e };
    }

    pub fn x(self: Vec3) f32 {
        return self.e[0];
    }

    pub fn y(self: Vec3) f32 {
        return self.e[1];
    }

    pub fn z(self: Vec3) f32 {
        return self.e[2];
    }

    pub fn neg(self: Vec3) Vec3 {
        const e = .{
            -self.e[0],
            -self.e[1],
            -self.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[0] + other.e[0],
            self.e[1] + other.e[1],
            self.e[2] + other.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn mul(self: Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[0] * other.e[0],
            self.e[1] * other.e[1],
            self.e[2] * other.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn div(self: Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[0] / other.e[0],
            self.e[1] / other.e[1],
            self.e[2] / other.e[2],
        };
        return Vec3{ .e = e };
    }

    pub fn len(self: Vec3) f32 {
        return @sqrt(self.len_squared());
    }

    pub fn len_squared(self: Vec3) f32 {
        return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
    }

    pub fn scalar_mul(self: Vec3, t: f32) Vec3 {
        const e = .{
            self.e[0] * t,
            self.e[1] * t,
            self.e[2] * t,
        };
        return Vec3{ .e = e };
    }

    pub fn scalar_div(self: Vec3, t: f32) Vec3 {
        const e = .{
            self.e[0] / t,
            self.e[1] / t,
            self.e[2] / t,
        };
        return Vec3{ .e = e };
    }

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.e[0] * other.e[0] + self.e[1] * other.e[1] + self.e[2] * other.e[2];
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        const e = .{
            self.e[1] * other.e[2] - self.e[2] * other.e[1],
            self.e[2] * other.e[0] - self.e[0] * other.e[2],
            self.e[0] * other.e[1] - self.e[1] * other.e[0],
        };
        return Vec3{ .e = e };
    }

    pub fn unit_vector(v: Vec3) Vec3 {
        return v.scalar_div(v.len());
    }
};

const Point3 = Vec3;
