const std = @import("std");
const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const time = rp2xxx.time;

const pin_config = rp2xxx.pins.GlobalConfiguration{
    .GPIO13 = .{ .name = "button", .direction = .in },
    .GPIO15 = .{ .name = "led", .direction = .out },
};

const pins = pin_config.pins();
const pin_button: rp2xxx.gpio.Pin = pins.button;
const pin_led: rp2xxx.gpio.Pin = pins.led;

pub fn main() !void {
    pin_config.apply();

    var last_state: u1 = 1;

    while (true) {
        const state = pin_button.read();
        std.mem.doNotOptimizeAway(state);

        if (last_state == 0 and state != 0) {
            time.sleep_ms(40); // debounce
            pin_led.toggle();
        }

        last_state = state;
    }
}
