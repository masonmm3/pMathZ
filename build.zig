const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Define the module for the library and tests
    const pMathz_module = b.addModule("pMathz", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const pMathz_lib = b.addLibrary(.{
        .name = "pMathz",
        .root_module = pMathz_module,
    });

    b.installArtifact(pMathz_lib);
}
