const std = @import("std");
const microzig = @import("microzig");

const MicroBuild = microzig.MicroBuild(.{
    .rp2xxx = true,
});

const projects = [_]Project{
    .{ .name = "blink_pin", .source_file = "src/blink-pin/main.zig" },
    .{ .name = "button_led", .source_file = "src/button-led/main.zig" },
};

pub fn build(b: *std.Build) void {
    const mz_dep = b.dependency("microzig", .{});
    const mb = MicroBuild.init(b, mz_dep) orelse return;

    const optimize = b.standardOptimizeOption(.{});

    const flash_project_name = b.option([]const u8, "flash-project", "Name of the project to flash");
    if (flash_project_name) |selected| {
        _ = findProjectOrPanic(b.allocator, selected);
    }

    const check_step = b.step("check", "Check if foo compiles");


    for (&projects) |project| {
        const firmware = mb.add_firmware(.{
            .name = project.name,
            .target = mb.ports.rp2xxx.boards.raspberrypi.pico,
            .optimize = optimize,
            .root_source_file = b.path(project.source_file),
        });

        const install_step = mb.add_install_firmware(firmware, .{});
        mb.builder.getInstallStep().dependOn(&install_step.step);
        mb.install_firmware(firmware, .{ .format = .elf });

        check_step.dependOn(&install_step.step);

        if (flash_project_name) |selected| {
            if (std.mem.eql(u8, selected, project.name)) {
                const uf2_filename = std.fmt.allocPrint(b.allocator, "{s}.uf2", .{project.name}) catch @panic("OOM");
                const uf2_path = b.pathJoin(&.{ b.install_prefix, "firmware", uf2_filename });

                const run_picotool = b.addSystemCommand(&.{
                    "picotool", "load", "-x", uf2_path,
                });
                run_picotool.step.dependOn(&install_step.step);
                b.default_step.dependOn(&run_picotool.step);
            }
        }
    }
}

fn findProjectOrPanic(allocator: std.mem.Allocator, name: []const u8) *const Project {
    for (&projects) |*project| {
        if (std.mem.eql(u8, project.name, name)) {
            return project;
        }
    }
    const msg = std.fmt.allocPrint(allocator, "Unknown project name: {s}", .{name}) catch "Unknown project";
    @panic(msg);
}

const Project = struct {
    name: []const u8,
    source_file: []const u8,
};
