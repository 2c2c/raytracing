const std = @import("std");
const hittable = @import("hittable.zig");
const ray = @import("ray.zig");

pub const HittableList = struct {
    objects: std.ArrayList(*hittable.Hittable),

    pub fn empty(alloc: std.mem.Allocator) HittableList {
        const objects = std.ArrayList(*hittable.Hittable).init(alloc);
        return HittableList{ .objects = objects };
    }

    pub fn init(alloc: std.mem.Allocator, object: *hittable.Hittable) HittableList {
        const objects = std.ArrayList(*hittable.Hittable).init(alloc);
        objects.append(object);
        return HittableList{ .objects = objects };
    }

    const vtable = hittable.Hittable.VTable{
        .hit = &hit,
    };

    pub fn _hittable(hittable_list: *HittableList) hittable.Hittable {
        return hittable.Hittable{
            .ctx = @ptrCast(hittable_list),
            .vtable = &vtable,
        };
    }

    pub fn deinit(self: HittableList) !void {
        try self.objects.deinit();
    }
    pub fn add(self: *HittableList, object: *hittable.Hittable) !void {
        try self.objects.append(object);
    }

    pub fn hit(ctx: *anyopaque, r: *ray.Ray, ray_tmin: f32, ray_tmax: f32, rec: *hittable.HitRecord) bool {
        const self: *HittableList = @alignCast(@ptrCast(ctx));

        var temp_rec: hittable.HitRecord = undefined;
        var hit_anything = false;
        var closest_so_far = ray_tmax;

        for (self.objects.items) |object| {
            if (object.hit(r, ray_tmin, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};
