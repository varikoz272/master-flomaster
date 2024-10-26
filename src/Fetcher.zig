const std = @import("std");
const clap = @import("clap");
const init = @import("init.zig");
const kf = @import("known-folders");
const rc = @import("resources.zig");
const dbr = @import("debugger.zig");
const InputParser = @import("InputParser.zig");
const main = @import("main.zig");

pub fn fetchMod(allocator: std.mem.Allocator, github_link: []const u8, reinstall: bool) (std.fs.File.OpenError || std.os.windows.GetFinalPathNameByHandleError || std.posix.FchdirError || std.process.Child.SpawnError || std.mem.Allocator.Error || std.posix.DeleteDirError || error{NotFileOrDir} || std.posix.MakeDirError)!void {
    const original_cwd = std.fs.cwd();

    const repo_creator = repoCreatorFromGhLink(github_link);

    const absolute_mod_path = main.mfm_absolute_mod_path(allocator, repo_creator) catch unreachable;
    defer allocator.free(absolute_mod_path);

    if (reinstall) {
        dbr.log("{s} removing {s}...\n", .{ dbr.info_prefix, absolute_mod_path });
        deleteAbsolutePathWithSub(allocator, absolute_mod_path) catch |err| {
            if (err != error.FileNotFound) return err;
            dbr.log("{s} nothing to reinstall at {s}\n", .{ dbr.info_prefix, absolute_mod_path });
        };
    }

    std.fs.makeDirAbsolute(absolute_mod_path) catch |err| {
        if (err != error.PathAlreadyExists) return err;
        dbr.log("{s} creating modules path for {s}\n", .{ dbr.info_prefix, repo_creator });
    };
    const mod_dir = try std.fs.openDirAbsolute(absolute_mod_path, .{});
    try mod_dir.setAsCwd();

    var clone_process = std.process.Child.init(&[_][]const u8{ "git", "clone", github_link }, allocator);
    clone_process.stdin_behavior = .Pipe;

    dbr.log("{s} trying to clone into {s}:\n", .{ dbr.info_prefix, absolute_mod_path });
    const term = try clone_process.spawnAndWait();
    if (term.Exited != 0 and !reinstall)
        std.debug.print("{s} if you want to reinstall the module, run with -r\n", .{dbr.tip_prefix});

    try original_cwd.setAsCwd();
}

pub fn deleteAbsolutePathWithSub(allocator: std.mem.Allocator, absolute_path: []const u8) (std.fs.File.OpenError || std.fs.Dir.Iterator.Error || std.fs.Dir.DeleteFileError || std.mem.Allocator.Error || std.posix.DeleteDirError || error{NotFileOrDir})!void {
    const opened_dir = std.fs.openDirAbsolute(absolute_path, .{ .iterate = true }) catch |err| {
        if (err == error.FileNotFound) return;
        return err;
    };

    var iterator = opened_dir.iterate();
    while (try iterator.next()) |entry| {
        const absolute_entry_path = try std.mem.concat(allocator, u8, &[_][]const u8{ absolute_path, "/", entry.name });
        defer allocator.free(absolute_entry_path);
        // dbr.log("{s} removing {s}...\n", .{ dbr.info_prefix, absolute_entry_path });
        switch (entry.kind) {
            .directory => try deleteAbsolutePathWithSub(allocator, absolute_entry_path),
            .file, .sym_link => try std.fs.deleteFileAbsolute(absolute_entry_path),
            else => std.debug.print("{s} {s}\n", .{ dbr.err_prefix, absolute_entry_path }),
        }
    }

    try std.fs.deleteDirAbsolute(absolute_path);
}

/// lifetimes of github_link and output are the same
pub fn repoNameFromGhLink(github_link: []const u8) []const u8 {
    const has_git_at_end = std.mem.eql(u8, github_link[github_link.len - 4 ..], ".git");
    var start = if (has_git_at_end) github_link.len - 4 else github_link.len - 1;

    while (github_link[start] != '/') : (start -= 1) {}
    return github_link[start..if (has_git_at_end) github_link.len - 4 else github_link.len];
}

/// lifetimes of github_link and output are the same
pub fn repoCreatorFromGhLink(github_link: []const u8) []const u8 {
    const has_git_at_end = std.mem.eql(u8, github_link[github_link.len - 4 ..], ".git");
    var start = if (has_git_at_end) github_link.len - 4 else github_link.len - 1;

    while (github_link[start] != '/') : (start -= 1) {}
    const end = start;
    start -= 1; // ignore repo name

    while (github_link[start] != '/' and github_link[start] != ':') : (start -= 1) {}

    return github_link[start + 1 .. end];
}
