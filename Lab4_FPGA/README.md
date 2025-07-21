System Programming Lab 1 – GPIO, LPM & Interrupts

Overview

In Lab 1 we explore the MSP430x2xx/x4xx’s basic peripherals and low‑power features by:

GPIO Configuration: setting pin direction, pull-up/down resistors, and I/O modes.

Low‑Power Modes (LPM0–LPM4): entering/exiting low‑power states to minimize energy consumption.

Interrupt Handling: configuring GPIO interrupts for button presses and implementing ISR routines.

Software Layering: structuring firmware into BSP, HAL, API, and Application layers with a Finite State Machine (FSM).

We will implement an interrupt-driven FSM, demonstrating robust
