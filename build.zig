const std = @import("std");

pub fn build(b: *std.Build) void {
    const spirv_target = b.resolveTargetQuery(.{
        .cpu_arch = .spirv32,
        .os_tag = .vulkan,
        .cpu_model = .{ .explicit = &std.Target.spirv.cpu.vulkan_v1_2 },
        .ofmt = .spirv,
    });

    // CHANGE: Use b.addObject instead of b.addExecutable
    
    const spirv_shader_mod = b.addModule("vert_shader", .{
        .target = spirv_target,
        .optimize = .ReleaseFast,
        .root_source_file = b.path("src/shaders/vertex.zig"),
    });

    const spirv_shader_object = b.addObject(.{
        .name = "vert_shader",
        .root_module = spirv_shader_mod, 
        .use_llvm = false, // Critical for the self-hosted SPIR-V backend
    });

    // Install the generated SPIR-V file.
    // The .getEmittedBin() method retrieves the path to the compiled binary.
    const install_shader_step = b.addInstallFile(spirv_shader_object.getEmittedBin(), "vert_shader.spv");

    install_shader_step.step.dependOn(&spirv_shader_object.step);

    b.getInstallStep().dependOn(&install_shader_step.step);
}
