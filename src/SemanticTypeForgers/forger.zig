const std = @import("std");

pub const PrimitiveValue = union(enum) {
    String: []const u8,
    Int: i64,
    Float: f64,
    Bool: bool,
    Null: void,
};

pub fn AtomicBehavior(comptime T: type) type {
    return struct {
        name: []const u8,

        const Self = @This();

        pub fn init(name: []const u8) Self {
            return Self{ .name = name };
        }

        pub fn getPrimitiveType(self: Self, v: T) T {
            _ = self;
            return v;
        }

        pub fn validate(self: Self, value: PrimitiveValue) bool {
            if (std.mem.eql(u8, self.name, "PersonEmail")) {
                switch (value) {
                    .String => |s| {
                        // Simplified zig email validation without importing full regex lib
                        return std.mem.indexOfScalar(u8, s, '@') != null and std.mem.indexOfScalar(u8, s, '.') != null;
                    },
                    else => return false,
                }
            }
            return false;
        }

        fn isWhitespace(c: u8) bool {
            return c == ' ' or c == '\t' or c == '\r' or c == '\n';
        }

        fn trim(s: []const u8) []const u8 {
            var start: usize = 0;
            while (start < s.len and isWhitespace(s[start])) : (start += 1) {}
            var end: usize = s.len;
            while (end > start and isWhitespace(s[end - 1])) : (end -= 1) {}
            return s[start..end];
        }

        fn toLower(allocator: std.mem.Allocator, s: []const u8) ![]u8 {
            var res = try allocator.alloc(u8, s.len);
            for (s, 0..) |c, i| {
                res[i] = std.ascii.toLower(c);
            }
            return res;
        }

        pub fn primitiveStringToValue(self: Self, allocator: std.mem.Allocator, val: []const u8) !PrimitiveValue {
            _ = self;
            const trimmed = trim(val);
            const lower = try toLower(allocator, trimmed);
            defer allocator.free(lower);

            if (trimmed.len == 0) return PrimitiveValue{ .String = val };
            if (std.mem.eql(u8, trimmed, "{}") or std.mem.eql(u8, trimmed, "[]")) return PrimitiveValue{ .Int = 0 };
            if (std.mem.eql(u8, lower, "true")) return PrimitiveValue{ .Bool = true };
            if (std.mem.eql(u8, lower, "false")) return PrimitiveValue{ .Bool = false };
            if (std.mem.eql(u8, lower, "null") or std.mem.eql(u8, lower, "undefined")) return PrimitiveValue{ .Null = {} };

            // Simple float check
            const is_float = std.mem.indexOfScalar(u8, trimmed, '.') != null or std.mem.indexOfScalar(u8, lower, 'e') != null;
            if (is_float) {
                if (std.fmt.parseFloat(f64, trimmed)) |f| {
                    return PrimitiveValue{ .Float = f };
                } else |_| {}
            } else {
                if (std.fmt.parseInt(i64, trimmed, 10)) |i| {
                    return PrimitiveValue{ .Int = i };
                } else |_| {}
            }

            return PrimitiveValue{ .String = val };
        }

        pub fn convertToPrimitive(self: Self, allocator: std.mem.Allocator, val: PrimitiveValue) !PrimitiveValue {
            switch (val) {
                .String => |s| return self.primitiveStringToValue(allocator, s),
                else => return val,
            }
        }

        pub fn forge(self: Self, v: T) T {
            // Validation requires PrimitiveValue, but forge takes T.
            // Simplified for concept as with Rust.
            _ = self;
            return v;
        }

        pub fn processValueMap(self: Self, allocator: std.mem.Allocator, map: std.StringHashMap(PrimitiveValue)) !PrimitiveValue {
            if (map.contains("productPrice")) {
                var p_price: f64 = 0;
                var p_discount: f64 = 0;
                var d_price: f64 = 0;
                var p_fees: f64 = 0;

                inline for (.{ "productPrice", "productDiscount", "deliveryPrice", "paymentFees" }, .{ &p_price, &p_discount, &d_price, &p_fees }) |key, ptr| {
                    if (map.get(key)) |v| {
                        const prim = try self.convertToPrimitive(allocator, v);
                        switch (prim) {
                            .Float => |f| ptr.* = f,
                            .Int => |i| ptr.* = @floatFromInt(i),
                            else => ptr.* = 0,
                        }
                    } else {
                        ptr.* = 0;
                    }
                }

                return PrimitiveValue{ .Float = p_price - p_discount + d_price + p_fees };
            }

            return PrimitiveValue{ .Null = {} };
        }
    };
}
