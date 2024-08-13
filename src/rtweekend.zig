const std = @import("std");

pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * std.math.pi / 180.0;
}

pub fn rand_range(min: f64, max: f64) f64 {
    return min + std.rand.float(std.Random.Xoshiro256, f64) * (max - min);
}
