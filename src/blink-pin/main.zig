const std = @import("std");
const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const gpio = rp2xxx.gpio;
const time = rp2xxx.time;

const led = gpio.num(15);

pub fn main() !void {
    led.set_function(.sio);
    led.set_direction(.out);

    while (true) {
        led.toggle();
        time.sleep_ms(1000);
    }
}
