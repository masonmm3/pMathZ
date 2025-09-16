const std = @import("std");

//Error enums

const mathError = error{divByZero};

//enums

//Structs
pub const Vec2d = struct {
    x: f32 = 0,
    y: f32 = 0,

    ///modifies the current value,
    ///variable must not be const
    pub fn Set(this: *Vec2d, x: ?f32, y: ?f32) Vec2d {
        var copyValue = Vec2d{};
        if (x) |setX| {
            this.x = setX;
            copyValue.x = setX;
        } else {
            copyValue.x = this.x;
        }

        if (y) |setY| {
            this.y = setY;
            copyValue.y = setY;
        } else {
            copyValue.y = this.y;
        }

        return copyValue;
    }

    ///adds other to this object
    ///returns a new object
    pub fn Add(this: Vec2d, other: Vec2d) Vec2d {
        const vec = Vec2d{ .x = this.x + other.x, .y = this.y + other.y };

        return vec;
    }

    ///subtracts this object from other.
    ///returns a new object
    pub fn Subtract(this: Vec2d, other: Vec2d) Vec2d {
        const vec = Vec2d{
            .x = this.x - other.x,
            .y = this.y - other.y,
        };

        return vec;
    }

    ///multiplies this object by other
    ///returns a new object
    pub fn Multiply(this: Vec2d, other: Vec2d) Vec2d {
        const vec = Vec2d{
            .x = this.x * other.x,
            .y = this.y * other.y,
        };

        return vec;
    }

    ///divides this by other
    ///returns a new object
    ///fails if other is 0,0. doesnt operate on the one thats 0 if only one is 0
    pub fn Divide(this: Vec2d, other: Vec2d) !Vec2d {
        if (other.x == 0 and other.y == 0) {
            return mathError.divByZero;
        }

        var vec = Vec2d{ .x = this.x, .y = this.y };

        if (other.x != 0) {
            vec.x = this.x / other.x;
        }

        if (other.y != 0) {
            vec.y = this.y / other.y;
        }

        return vec;
    }

    //returns the dot product
    pub fn Dot(this: Vec2d, other: Vec2d) f32 {
        const dot: f32 = (this.x * other.x) + (this.y * other.y);

        return dot;
    }

    ///scale the variable by a number
    pub fn scale(this: Vec2d, scalar: f32) Vec2d {
        return Vec2d{ .x = this.x * scalar, .y = this.y * scalar };
    }

    ///divide everything by the scalar
    pub fn scalarDivide(this: Vec2d, scalar: f32) Vec2d {
        return Vec2d{ .x = this.x / scalar, .y = this.y / scalar };
    }

    pub fn maxMag(this: Vec2d, mag: f32) Vec2d {
        if (mag == 0) {
            return Vec2d{};
        }

        const length = this.magnitude();

        const ratio = mag / length;

        return this.scale(ratio);
    }

    ///get the magnitude of the value
    pub fn magnitude(this: Vec2d) f32 {
        const sqrMag: f32 = (this.x * this.x) + (this.y * this.y);

        return std.math.sqrt(sqrMag);
    }
};

pub const Line = struct {
    point: Vec2d,
    angle: f32,

    ///projects an external point onto the line
    pub fn projectPoint(self: Line, point: Vec2d) Vec2d {
        const A = self.point;
        const B = Vec2d{
            .x = A.x + std.math.cos(self.angle),
            .y = A.y + std.math.sin(self.angle),
        };

        const AB = B.Subtract(A);
        const AP = point.Subtract(A);

        const dot_product_AP_AB = AP.Dot(AB);
        const dot_product_AB_AB = AB.Dot(AB);
        const t = dot_product_AP_AB / dot_product_AB_AB;

        const projected_vec = AB.scale(t);
        const closest_point = A.Add(projected_vec);

        return closest_point;
    }
};

//funcitons
pub fn MeterToInch(meter: f32) f32 {
    return meter * 39.3701;
}

pub fn InchToMeter(inch: f32) f32 {
    return inch * 0.0254;
}

//tests
test "Mutiply-Vec2d" {
    const vec1 = Vec2d{ .x = 2, .y = 3 };
    const vec2 = Vec2d{ .x = 4, .y = 5 };
    const expect = Vec2d{ .x = 8, .y = 15 };

    const result = Vec2d.Multiply(vec1, vec2);

    try std.testing.expectEqual(expect.x, result.x);
    try std.testing.expectEqual(expect.y, result.y);
}

test "Divide-Vec2d" {
    const variable = Vec2d{ .x = 10, .y = 10 };

    const standard = Vec2d{ .x = 2, .y = 2 };
    const one0 = Vec2d{ .x = 2, .y = 0 };
    const error0 = Vec2d{ .x = 0, .y = 0 };

    const sResult = try Vec2d.Divide(variable, standard);
    const oResult = try Vec2d.Divide(variable, one0);

    try std.testing.expectEqual(5, sResult.x);
    try std.testing.expectEqual(5, sResult.y);

    try std.testing.expectEqual(5, oResult.x);
    try std.testing.expectEqual(10, oResult.y);

    try std.testing.expectError(mathError.divByZero, Vec2d.Divide(variable, error0));
}

test "Add-Vec2d" {
    const vec1 = Vec2d{};

    const add = Vec2d{ .x = 1, .y = 1 };

    const result = Vec2d.Add(vec1, add);

    try std.testing.expectEqual(1, result.x);
    try std.testing.expectEqual(1, result.y);
}

test "Subtract-Vec2d" {
    const vec1 = Vec2d{ .x = 1, .y = 1 };

    const sub = Vec2d{ .x = 1, .y = 1 };

    const result = Vec2d.Subtract(vec1, sub);

    try std.testing.expectEqual(0, result.x);
    try std.testing.expectEqual(0, result.y);
}

test "Set-Vec2d" {
    var set = Vec2d{};

    _ = set.Set(2, 5);

    try std.testing.expectEqual(2, set.x);
    try std.testing.expectEqual(5, set.y);

    _ = set.Set(null, 2);

    try std.testing.expectEqual(2, set.x);
    try std.testing.expectEqual(2, set.y);
}

test "Dot-Vec2d" {
    const dot = Vec2d{ .x = 8, .y = 10 };

    const other = Vec2d{ .x = 1, .y = 2 };

    const result = Vec2d.Dot(dot, other);

    try std.testing.expectEqual(28, result);
}

test "Mag-Vec2d" {
    const variable = Vec2d{ .x = 5, .y = 5 };

    try std.testing.expectApproxEqAbs(7.071, variable.magnitude(), 0.01);
}

test "Scale-Vec2d" {
    const variable = Vec2d{ .x = 10, .y = 8 };

    const result = variable.scale(0.25);

    try std.testing.expectEqual(2.5, result.x);
    try std.testing.expectEqual(2, result.y);
}

test "MaxMag-Vec2d" {
    const variable = Vec2d{ .x = 10, .y = 8 };

    const mag1 = variable.maxMag(1);

    try std.testing.expectEqual(1, mag1.magnitude());
    try std.testing.expectApproxEqAbs(0.7809, mag1.x, 0.01);
    try std.testing.expectApproxEqAbs(0.6247, mag1.y, 0.01);
}

//this test is ai generated as i dont feel like doing a bunch of complex edge case projections by hand
test "Projection-Line" {
    // Test Case 1: Point directly on the line (horizontal line)
    {
        const line = Line{ .point = Vec2d{ .x = 0, .y = 0 }, .angle = 0 };
        const point = Vec2d{ .x = 5, .y = 0 }; // Point already on the line
        const projPoint = line.projectPoint(point);
        try std.testing.expectApproxEqAbs(5.0, projPoint.x, 0.00001);
        try std.testing.expectApproxEqAbs(0.0, projPoint.y, 0.00001);
    }

    // Test Case 2: Point above a horizontal line
    {
        const line = Line{ .point = Vec2d{ .x = 0, .y = 0 }, .angle = 0 };
        const point = Vec2d{ .x = 1, .y = 1 }; // Original test case
        const projPoint = line.projectPoint(point);
        try std.testing.expectApproxEqAbs(1.0, projPoint.x, 0.00001);
        try std.testing.expectApproxEqAbs(0.0, projPoint.y, 0.00001);
    }

    // Test Case 3: Point below a horizontal line
    {
        const line = Line{ .point = Vec2d{ .x = 2, .y = 0 }, .angle = 0 };
        const point = Vec2d{ .x = 2, .y = -3 };
        const projPoint = line.projectPoint(point);
        try std.testing.expectApproxEqAbs(2.0, projPoint.x, 0.00001);
        try std.testing.expectApproxEqAbs(0.0, projPoint.y, 0.00001);
    }

    // Test Case 4: Point on a vertical line
    {
        const line = Line{ .point = Vec2d{ .x = 0, .y = 0 }, .angle = std.math.pi / 2.0 }; // 90 degrees
        const point = Vec2d{ .x = 1, .y = 1 };
        const projPoint = line.projectPoint(point);
        try std.testing.expectApproxEqAbs(0.0, projPoint.x, 0.00001);
        try std.testing.expectApproxEqAbs(1.0, projPoint.y, 0.00001);
    }

    // Test Case 5: Point on a diagonal line (45 degrees)
    {
        const line = Line{ .point = Vec2d{ .x = 0, .y = 0 }, .angle = std.math.pi / 4.0 }; // 45 degrees
        const point = Vec2d{ .x = 0, .y = 2 }; // A point not on the line
        const projPoint = line.projectPoint(point);
        // The line equation is y = x. The perpendicular from (0,2) to y=x is y-2 = -1*(x-0) => y = -x + 2.
        // Intersection: x = -x + 2 => 2x = 2 => x = 1. So, y = 1.
        try std.testing.expectApproxEqAbs(1.0, projPoint.x, 0.00001);
        try std.testing.expectApproxEqAbs(1.0, projPoint.y, 0.00001);
    }

    // Test Case 6: Point and line shifted (horizontal line, non-origin point)
    {
        const line = Line{ .point = Vec2d{ .x = 5, .y = 10 }, .angle = 0 }; // Horizontal line at y=10
        const point = Vec2d{ .x = 7, .y = 12 };
        const projPoint = line.projectPoint(point);
        try std.testing.expectApproxEqAbs(7.0, projPoint.x, 0.00001);
        try std.testing.expectApproxEqAbs(10.0, projPoint.y, 0.00001);
    }

    // Test Case 7: Point and line shifted (vertical line, non-origin point)
    {
        const line = Line{ .point = Vec2d{ .x = 5, .y = 10 }, .angle = std.math.pi / 2.0 }; // Vertical line at x=5
        const point = Vec2d{ .x = 3, .y = 8 };
        const projPoint = line.projectPoint(point);
        try std.testing.expectApproxEqAbs(5.0, projPoint.x, 0.00001);
        try std.testing.expectApproxEqAbs(8.0, projPoint.y, 0.00001);
    }

    // Test Case 8: Point behind the line's starting point (but still projects onto the infinite line)
    // Assuming projectPoint projects onto the infinite line defined by point and angle.
    {
        const line = Line{ .point = Vec2d{ .x = 5, .y = 0 }, .angle = 0 }; // Horizontal line starting at x=5
        const point = Vec2d{ .x = 0, .y = 2 };
        const projPoint = line.projectPoint(point);
        try std.testing.expectApproxEqAbs(0.0, projPoint.x, 0.00001);
        try std.testing.expectApproxEqAbs(0.0, projPoint.y, 0.00001);
    }
}
