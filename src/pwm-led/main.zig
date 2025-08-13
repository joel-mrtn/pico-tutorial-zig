const std = @import("std");
const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const time = rp2xxx.time;

const pin_config = rp2xxx.pins.GlobalConfiguration{
    .GPIO15 = .{ .name = "led", .function = .PWM7_B },
};

const pins = pin_config.pins();
const pwm_led: rp2xxx.pwm.Pwm = pins.led;

const delay: u32 = 10;

pub fn main() !void {
    pin_config.apply();

    pwm_led.slice().set_wrap(255);
    pwm_led.slice().enable();

    while (true) {
        for (0..256) |level| {
            pwm_led.set_level(@truncate(level));
            time.sleep_ms(delay);
        }
        for (0..255) |level| {
            pwm_led.set_level(@truncate(255 - level));
            time.sleep_ms(delay);
        }
    }
}
