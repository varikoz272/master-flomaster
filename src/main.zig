const std = @import("std");
const clap = @import("clap");
const init = @import("init.zig");
const kf = @import("known-folders");
const rc = @import("resources.zig");
const dbr = @import("debugger.zig");
const InputParser = @import("InputParser.zig");

pub const mfm_subpath = "/master-flomaster";
pub const modules_subpath = mfm_subpath ++ "/mods";
pub const templates_subpath = mfm_subpath ++ "/tmpl";

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    InputParser.parseInput(gpa.allocator());
}

pub fn mfm_absolute_path(allocator: std.mem.Allocator) kf.Error![]u8 {
    const cache_path_null = try kf.getPath(allocator, .cache);
    const cache_path: []const u8 = cache_path_null orelse return kf.Error.ParseError;
    const mfm_path = std.mem.concat(allocator, u8, &[_][]const u8{ cache_path, mfm_subpath }) catch return kf.Error.OutOfMemory;
    allocator.free(cache_path);

    return mfm_path;
}

pub fn mfm_absolute_mods_path(allocator: std.mem.Allocator) kf.Error![]u8 {
    const cache_path_null = try kf.getPath(allocator, .cache);
    const cache_path: []const u8 = cache_path_null orelse return kf.Error.ParseError;
    const mfm_mods_path = std.mem.concat(allocator, u8, &[_][]const u8{ cache_path, modules_subpath }) catch return kf.Error.OutOfMemory;
    allocator.free(cache_path);

    return mfm_mods_path;
}

pub fn mfm_absolute_mod_path(allocator: std.mem.Allocator, repo_creator: []const u8) kf.Error![]u8 {
    const cache_path_null = try kf.getPath(allocator, .cache);
    const cache_path: []const u8 = cache_path_null orelse return kf.Error.ParseError;
    const mfm_mod_path = try std.mem.concat(allocator, u8, &[_][]const u8{ cache_path, modules_subpath, "/", repo_creator });
    allocator.free(cache_path);

    return mfm_mod_path;
}

pub fn mfm_absolute_tmpl_path(allocator: std.mem.Allocator) kf.Error![]u8 {
    const cache_path_null = try kf.getPath(allocator, .cache);
    const cache_path: []const u8 = cache_path_null orelse return kf.Error.ParseError;
    const mfm_tmpl_path = std.mem.concat(allocator, u8, &[_][]const u8{ cache_path, templates_subpath }) catch return kf.Error.OutOfMemory;
    allocator.free(cache_path);

    return mfm_tmpl_path;
}
