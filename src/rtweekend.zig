const std = @import("std");

pub fn degrees_to_radians(degrees: f32) f32 {
    return degrees * std.math.pi / 180.0;
}
