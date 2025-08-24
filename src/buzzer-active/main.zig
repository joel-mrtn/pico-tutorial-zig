const std = @import("std");
const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const time = rp2xxx.time;

const pin_config = rp2xxx.pins.GlobalConfiguration{
    .GPIO15 = .{ .name = "buzzer", .direction = .out },
    .GPIO16 = .{ .name = "button", .direction = .in, .pull = .up },
};

const pins = pin_config.pins();
const buzzer: rp2xxx.gpio.Pin = pins.buzzer;
const button: rp2xxx.gpio.Pin = pins.button;

pub fn main() !void {
    pin_config.apply();

    while (true) {
        if (button.read() == 1) {
            buzzer.put(0);
        } else {
            buzzer.put(1);
        }
    }
}
