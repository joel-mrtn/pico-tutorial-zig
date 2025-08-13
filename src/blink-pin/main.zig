const std = @import("std");
const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const time = rp2xxx.time;

const pin_config = rp2xxx.pins.GlobalConfiguration{
    .GPIO15 = .{
        .name = "led",
        .direction = .out,
    },
};

const pins = pin_config.pins();
const pin_led: rp2xxx.gpio.Pin = pins.led;

pub fn main() !void {
    pin_config.apply();

    while (true) {
        pin_led.toggle();
        time.sleep_ms(1000);
    }
}
