const std = @import("std");

pub const ansi_green = "\x1b[32m";
pub const ansi_yellow = "\x1b[33m";
pub const ansi_red = "\x1b[31m";

pub const ansi_color_reset = "\x1b[0m";

pub const info_prefix = ansi_green ++ "[INFO]" ++ ansi_color_reset;
pub const warning_prefix = ansi_yellow ++ "[WARNING]" ++ ansi_color_reset;
pub const err_prefix = ansi_red ++ "[ERROR]" ++ ansi_color_reset;
pub const tip_prefix = ansi_green ++ "[TIP]" ++ ansi_color_reset;

pub var print_debug = true;

pub fn log(comptime fmt: []const u8, args: anytype) void {
    if (print_debug) std.debug.print(fmt, args);
}
