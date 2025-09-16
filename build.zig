const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add a step to create a static library with the name "pMathz"
    const lib = b.addStaticLibrary(.{
        .name = "pMathz",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Make the install step depend on this library
    b.installArtifact(lib);

    // Creates a module that other projects can import
    const mod = b.addModule("pMathz", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Expose the module as a dependency. This allows other projects to link to the library.
    b.addModule("pMathz", mod);

    const main_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
