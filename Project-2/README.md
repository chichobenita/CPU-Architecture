# CPU Architecture LAB2 – VHDL Part 2: Sequential Code & Behavioral Modeling

## Overview

In LAB2 of our CPU Architecture course, we will develop and verify a synchronous, N-modulo counter whose maximum count (`UpperBound`) can change dynamically at runtime.  The counter will:

- Count from 0 up to `UpperBound`
- Roll over back to 0, then continue counting
- Update `UpperBound` on-the-fly via a control input  
- Be implemented behaviorally in VHDL using only `top.vhd` and `aux_package.vhd`

We will provide a single, comprehensive test bench (`tb4.vhd`) to exercise all counter behaviors and generate waveform outputs for validation.

## Repository Structure

```text
Project-2/                  # root directory
├── DUT/                    # Design-Under-Test (VHDL source files)
│   ├── aux_package.vhd     # constants, types & utility functions
│   └── top.vhd             # behavioral implementation of dynamic counter
├── TB/                     # Test benches
│   └── tb4.vhd             # test bench for dynamic counter functionality
├── SIM/                    # Simulation scripts
│   ├── list_tb4.do         # ModelSim compile & elaborate script
│   └── wave_tb4.do         # ModelSim simulation & waveform dump script
├── DOC/                    # Documentation
│   ├── readme.txt          # list of DUT files with brief descriptions
│   └── lab2 task.pdf       # lab assignment text, block diagrams & expected waveforms
└── README.md               # this document
