# PWM Generator Module
## 1. Purpose

The PWM generator produces a fixed-frequency square wave whose duty cycle is controlled by a runtime input,
`duty_cycle`. By varying
duty cycle, the average voltage delivered
is controlled without needing any analog circuitry.

## 2. Interface

| Port         | Direction | Width        | Description                              |
|--------------|-----------|--------------|-------------------------------------------|
| `clk`        | input     | 1            | System clock                              |
| `resetn`     | input     | 1            | Active-low asynchronous reset             |
| `duty_cycle` | input     | `PWM_WIDTH`  | Runtime duty cycle command, 0 to 2^N - 1  |
| `pwm_out`    | output    | 1            | PWM output signal                         |

**Parameter:** `PWM_WIDTH` — sets the duty-cycle resolution. An 8-bit width
gives 256 discrete duty cycle steps (0–255).

## 3. Architecture

### Counter + Comparator

This is a **counter + comparator** PWM generator, uses a free running
counter that
ramps from `0` to `2^PWM_WIDTH - 1` and wraps back to `0`, continuously.
The output is a purely combinational function of
the counter's current value against the `duty_cycle` register:

```math
pwm\_out = (counter < duty\_cycle)
```

Visualized as a sawtooth ramp (the counter) against a horizontal threshold
line (`duty_cycle`): wherever the ramp sits below the threshold, the output
is high; above it, low. Raising `duty_cycle` widens the high portion of
each period — a higher duty cycle. The comparator has no memory of its own
and needs no clock; it simply reflects the present relationship between two
values at all times, which is why it's implemented as a continuous
assignment (`assign`) rather than inside a clocked block.

The reset is **asynchronous and active-low** — the counter clears
immediately on `negedge resetn`, independent of the clock edge.

### Frequency math

The counter completes one full ramp every `2^PWM_WIDTH` input clock
cycles, so:

```
T_period = 2^PWM_WIDTH x T_clk
f_pwm    = f_clk / 2^PWM_WIDTH
```

Critically, the **number of high cycles per period equals `duty_cycle`
exactly** — not approximately. Since the counter visits every integer value
from `0` to `2^PWM_WIDTH - 1` exactly once per period, the comparator is
true for precisely `duty_cycle` of those cycles. This is the ground truth
the testbench checks against — an exact integer equality, not a percentage
or tolerance-based comparison.

## 4. Testbench

The testbench measures, over a window of exactly `2^PWM_WIDTH` consecutive
clock cycles, how many of those cycles had `pwm_out` high, and compares
that count against the `duty_cycle` value driven during that window.
Because any window of that exact length contains every counter value
exactly once regardless of which phase of the ramp sampling begins on,
period-boundary detection is unnecessary — the window length alone
guarantees a correct measurement.

Two persistent counters drive this: `clock_counter` tracks progress through
the current window, and `test_counter` accumulates high cycles. Both
increment by exactly one per real `posedge clk` inside a single
`always_ff` block — no software-style loop is used here, since looping
inside a clocked block executes all iterations in zero simulation time
rather than across real clock edges. The duty-cycle sweep itself, by
contrast, *does* use a `for` loop — legally, since it lives inside the
`initial` block, a procedural/sequential context where each loop iteration
is separated by a real `#delay`.

## 5. How to run

```bash
mkdir -p sim
iverilog -g2012 -o sim/pwm_gen.vpp rtl/pwm_gen.sv tb/pwm_tb.sv
vvp sim/pwm_gen.vpp
gtkwave sim/pwm_tb.vcd
```

**Note:** as with the clock divider, the `sim/` directory must exist
*before* running `vvp`, or the `$dumpfile` call fails silently from
GTKWave's perspective (loudly from the simulator console) and no waveform
is produced.

## 6. Verification result

Simulated across a duty-cycle sweep (`0, 32, 64, ..., 224`, plus the `255`
boundary case). Waveform confirms:
- `clk` toggles cleanly throughout.
- `pwm_out` produces visibly widening high pulses as `duty_cycle`
  increases across the sweep, consistent with the counter + comparator
  architecture.
- The self-checking testbench reports `PASS` for every duty cycle in the
  sweep, including the `0` and `255` edge cases, confirming the measured
  high-cycle count matches `duty_cycle` exactly each time.

![Simulated GTKwave output of PWM generator](images\PWM_Simulation.png)
