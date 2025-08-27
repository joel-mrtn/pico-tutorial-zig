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

const VOLUME = 0.05;

pub fn main() !void {
    pin_config.apply();

    while (true) {
        const state = button.read();
        std.mem.doNotOptimizeAway(state);

        if (state == 0) {
            var x: f32 = 0.0;
            while (x < 360.0) : (x += 10.0) {
                // Oscillate between 1500 and 2500 Hz
                const radians = x * (std.math.pi / 180.0);
                const sin_val = std.math.sin(radians);
                const tone_val: i32 = @intFromFloat(2000.0 + sin_val * 500.0);

                setFreq(buzzer, tone_val, 10, VOLUME);
            }
        } else {
            setFreq(buzzer, 0, 10, VOLUME);
        }
        time.sleep_ms(10);
    }
}

fn setFreq(pin: rp2xxx.gpio.Pin, freq: i32, times: i32, volume: f32) void {
    if (freq == 0) {
        pin.put(0);
    } else {
        const f = @as(f64, @floatFromInt(freq));
        const on_time: u32 = @intFromFloat((1_000_000.0 / f) * @as(f64, volume));
        const off_time: u32 = @intFromFloat((1_000_000.0 / f) * (1.0 - @as(f64, volume)));

        const cycles: i32 = @divTrunc(times * freq, 1000);

        var i: i32 = 0;
        while (i < cycles) : (i += 1) {
            pin.put(1);
            time.sleep_us(on_time);
            pin.put(0);
            time.sleep_us(off_time);
        }
    }
}
