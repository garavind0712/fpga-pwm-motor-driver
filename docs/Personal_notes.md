# Personal Notes
### Why PWM?
Your microcontroller or FPGA can only output two voltage levels: high (say 3.3V or 5V) or low (0V). It cannot output 2.1V or 1.7V — there's no analog output. So how do you give a motor "half voltage" to run at half speed?

You switch rapidly between full voltage and zero voltage. If you spend exactly half the time at full voltage and half at zero, the motor "sees" an average of half voltage. Your switching happens so fast (thousands of times per second) that the motor's mechanical inertia can't react to each individual pulse — it only responds to the average. So from the motor's perspective, it behaves as if you'd applied a steady half-voltage the whole time.

This is the entire reason PWM exists. You're using time-averaging to fake an analog voltage with a digital signal. Say D is the Duty cycle: % of time a signal stays high for. expressed as a fractino from 0 to 1.

```math
V_{average} = D × V_{supply}
```

With an 8-bit PWM (duty_cycle register from 0 to 255) and V_supply = 5V:
```math
V_{average} = (\text{duty cycle} / 255) × 5V
```
At duty_cycle = 128:  V_average ≈ 2.5; At duty_cycle = 255:  V_average = 5V; At duty_cycle = 0:    V_average = 0V


## What are first-order-systems?
A system that exponentially approaches a target value instead of jumping to it instantly. In this case, the motor rotating speed doesn't immediately jump to half speed when we apply 2.5 V to it, but it cgradually gets there, because of internal resistance caused by the coil AND motor's rotational inertia.