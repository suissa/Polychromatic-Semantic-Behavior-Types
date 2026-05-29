const std = @import("std");
const forger = @import("forger.zig");
const PrimitiveValue = forger.PrimitiveValue;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const behavior = forger.AtomicBehavior(i64).init("test");

    if (behavior.getPrimitiveType(5) != 5) return error.TestFailed;

    const r1 = try behavior.convertToPrimitive(allocator, PrimitiveValue{ .String = " 123 " });
    if (r1.Int != 123) return error.TestFailed;

    const r2 = try behavior.convertToPrimitive(allocator, PrimitiveValue{ .String = "true" });
    if (r2.Bool != true) return error.TestFailed;

    const r3 = try behavior.convertToPrimitive(allocator, PrimitiveValue{ .String = "{}" });
    if (r3.Int != 0) return error.TestFailed;

    var map = std.StringHashMap(PrimitiveValue).init(allocator);
    defer map.deinit();

    try map.put("productPrice", PrimitiveValue{ .String = "10.5" });
    try map.put("deliveryPrice", PrimitiveValue{ .Float = 2.5 });

    const r4 = try behavior.processValueMap(allocator, map);
    if (r4.Float != 13.0) return error.TestFailed;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Zig tests passed\n", .{});
}
