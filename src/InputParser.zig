const std = @import("std");
const main = @import("main.zig");
const clap = @import("clap");
const init = @import("init.zig");
const kf = @import("known-folders");
const rc = @import("resources.zig");
const dbr = @import("debugger.zig");
const Fetcher = @import("Fetcher.zig");
const exe_name = @import("../build.zig").exe_name;

pub const parsed_general_help =
    \\  -h, --help          show this. can be called at actions
    \\  -H, --hide-debug    hide runtime logs
    \\  -i, --no-init       force mfm to not init (see mfm init --help)
    \\
    \\  <str>               action (init/mod/tmpl)
    \\
    \\  -f, --fetch <str>
    \\  -r, --refetch       refetch if already module exists
;

pub const general_help =
    \\  -h, --help          show this. can be called at actions
    \\  -H, --hide-debug    hide runtime logs
    \\  -i, --no-init       force mfm to not init (see mfm init --help)
    \\
    \\  <str>               action (init/mod/tmpl)
    \\
;

pub const init_usage =
    \\  'mfm init' usage: initializes directories and configuration at the device
    \\  runs every time by default (to desable use -i)
    \\
;

pub const init_help =
    \\  -h, --help          show this. can be called at actions
    \\  -H, --hide-debug    hide runtime logs
    \\
;

pub const mod_usage =
    \\  'mfm mod' usage: allows to manipulate with modules (template dependencies)
    \\
;

pub const mod_help =
    \\  -h, --help          show this. can be called at actions
    \\  -H, --hide-debug    hide runtime logs
    \\
    \\  -f, --fetch <str>   fetch a github repository to the mods dir
    \\  -r, --refetch       refetch if already module exists
    \\
;

pub const ParsedInput = struct {};

pub fn parseInput(allocator: std.mem.Allocator) void {
    const params = comptime clap.parseParamsComptime(parsed_general_help);

    var input = clap.parse(clap.Help, &params, clap.parsers.default, .{ .allocator = allocator }) catch return;
    defer input.deinit();

    const need_help = input.args.help != 0;

    if (input.args.@"hide-debug" != 0) dbr.print_debug = false;

    init.checkOrInit(allocator) catch |err| {
        std.debug.print("{s}\nunable to init: {}{s}\n", .{ dbr.ansi_red ++ rc.fear, err, dbr.ansi_color_reset });
    };

    for (input.positionals) |pos| {
        if (std.mem.eql(u8, pos, "init")) {
            if (need_help) {
                std.debug.print("{s}\n{s}", .{ init_usage, init_help });
                return;
            }

            init.checkOrInit(allocator) catch |err| {
                std.debug.print("{s}\nunable to init: {}{s}\n", .{ dbr.ansi_red ++ rc.fear, err, dbr.ansi_color_reset });
            };

            return;
        }

        if (std.mem.eql(u8, pos, "mod")) {
            if (need_help) {
                std.debug.print("{s}\n{s}", .{ mod_usage, mod_help });
                return;
            }

            if (input.args.fetch) |link| {
                Fetcher.fetchMod(allocator, link, input.args.refetch != 0) catch |err| std.debug.print("{}\n", .{err});
                return;
            }
        }
    }

    if (need_help) {
        std.debug.print("usage:\n{s}\n", .{general_help});
        return;
    }
}
