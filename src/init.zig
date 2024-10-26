const std = @import("std");
const main = @import("main.zig");
const kf = @import("known-folders");
const dbr = @import("debugger.zig");

const init_all_dir = [3]*const fn (allocator: std.mem.Allocator) (kf.Error || std.posix.MakeDirError)!void{ initMfmDir, initModsDir, initTmplDir };

pub fn checkOrInit(allocator: std.mem.Allocator) (kf.Error || std.posix.MakeDirError)!void {
    for (init_all_dir) |init| {
        init(allocator) catch |err| {
            if (err != std.posix.MakeDirError.PathAlreadyExists) return err;
            dbr.log("already exists!\n", .{});
        };
    }
}

fn initMfmDir(allocator: std.mem.Allocator) (kf.Error || std.posix.MakeDirError)!void {
    const mfm_absolute_path = try main.mfm_absolute_path(allocator);
    defer allocator.free(mfm_absolute_path);

    defer dbr.log("\n", .{});

    dbr.log("{s} creating mfm directory at {s}...", .{ dbr.info_prefix, mfm_absolute_path });
    std.fs.makeDirAbsolute(mfm_absolute_path) catch |err| {
        if (err != std.posix.MakeDirError.PathAlreadyExists) return err;
        dbr.log("already exists!", .{});
    };
}

pub fn initModsDir(allocator: std.mem.Allocator) (kf.Error || std.posix.MakeDirError)!void {
    const mfm_absolute_mods_path = try main.mfm_absolute_mods_path(allocator);
    defer allocator.free(mfm_absolute_mods_path);

    defer dbr.log("\n", .{});

    dbr.log("{s} creating mods directory at {s}...", .{ dbr.info_prefix, mfm_absolute_mods_path });
    std.fs.makeDirAbsolute(mfm_absolute_mods_path) catch |err| {
        if (err != std.posix.MakeDirError.PathAlreadyExists) return err;
        dbr.log("already exists!", .{});
    };
}

pub fn initTmplDir(allocator: std.mem.Allocator) (kf.Error || std.posix.MakeDirError)!void {
    const mfm_absolute_tmpl_path = try main.mfm_absolute_tmpl_path(allocator);
    defer allocator.free(mfm_absolute_tmpl_path);

    defer dbr.log("\n", .{});

    dbr.log("{s} creating templates directory at {s}...", .{ dbr.info_prefix, mfm_absolute_tmpl_path });
    std.fs.makeDirAbsolute(mfm_absolute_tmpl_path) catch |err| {
        if (err != std.posix.MakeDirError.PathAlreadyExists) return err;
        dbr.log("already exists! ", .{});
    };
}
