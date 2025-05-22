# CPU Architecture LAB3 – VHDL Part 3: Controller & Datapath Design

## Overview

In LAB3 of our CPU Architecture course, we will design and verify a multi-cycle RISC CPU by separating Control and Datapath.  We will:

- Implement the FSM-based Control Unit (SRMC-I methodology)  
- Integrate it with the Datapath to form a working CPU (`top.vhd`)  
- Perform file-based simulation of the complete DUT using external memory files  
- Analyze and document the behavior with annotated waveforms  

This preparation will set the stage for LAB4 (FPGA synthesis).

## Repository Structure

```text
Project-3/                  # root directory
├── DUT/                    # Design-Under-Test (VHDL source files)
│   ├── aux_package.vhd     # constants, types & utility functions
│   ├── datapath.vhd        # datapath components (ALU, registers, RAM)
│   ├── control.vhd         # FSM-based control unit
│   └── top.vhd             # top-level integration of Control and Datapath
├── TB/                     # Test benches
│   ├── tb_datapath.vhd     # Datapath-only tests
│   ├── tb_control.vhd      # Control-only tests
│   └── tb_top.vhd          # Full-system tests with file I/O
├── SIM/                    # Simulation scripts & memory files
│   ├── list_top.do         # compile & elaborate script
│   ├── wave_top.do         # run simulation & dump waveforms
│   ├── ITCM_init.bin       # instruction-memory initialization file
│   ├── DTCM_init.bin       # data-memory initialization file
│   └── DTCM_out.bin        # DUT’s data-memory output after run
├── DOC/                    # Documentation
│   ├── readme.txt          # brief file descriptions
│   ├── designGraph.pdf     # FSM state-transition chart
│   └── pre3.pdf            # lab report with block diagrams & annotated waveforms
└── README.md               # this document
