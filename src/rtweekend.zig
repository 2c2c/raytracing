const std = @import("std");

pub fn degrees_to_radians(degrees: f32) f32 {
    return degrees * std.math.pi / 180.0;
}

pub fn rand_range(min: f32, max: f32) f32 {
    return min + std.rand.float(std.Random.Xoshiro256, f32) * (max - min);
}
