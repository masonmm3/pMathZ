const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. Define the 'pMathz' library as a static library.
    const pMathz_lib = b.addStaticLibrary(.{
        .name = "pMathz",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 2. Add the library to the install step so it gets built.
    b.installArtifact(pMathz_lib);

    // 3. Create an executable that will use the library.
    // Let's call it "my_program" for clarity.
    const exe = b.addExecutable(.{
        .name = "my_program",
        .root_source_file = b.path("src/main.zig"), // Or whatever your main file is
        .target = target,
        .optimize = optimize,
    });

    // 4. Link the library to the executable.
    exe.linkLibrary(pMathz_lib);

    b.installArtifact(exe);

    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
