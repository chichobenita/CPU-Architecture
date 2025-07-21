# CPU Architecture LAB4 – FPGA-Based Digital Design

## Overview
In Lab 4 we migrate the synchronous digital system from Lab 1 onto a Cyclone II FPGA, then evaluate its performance, area utilization and timing, and finally validate its functionality in hardware on the DE10-Standard board.

Key objectives:
- **Functional Simulation** with maximal coverage (ModelSim)
- **FPGA Synthesis & Timing Analysis** (Quartus II)
- **Performance Metrics**: fₘₐₓ, logic usage, critical/shortest paths
- **Hardware Validation**: I/O on DE10 (switches, keys, LEDs, 7‑segment)
- **Signal Tap Debug** for internal signal capture

## Repository Structure
```text
Lab4_FPGA/
├── VHDL_Project/    # Synthesizable VHDL sources (top-level & submodules)
├── TB/              # Single tb.vhd for full-system verification
├── SIM/             # ModelSim scripts (.do) for compile & sim
├── Quartus/         # Quartus project (QPF, QSF, SDC, SOF bitstream)
├── SignalTap/       # Signal Tap project & .stp/.stpdb capture files
└── DOC/             # Documentation: Task definition, Lab4.pdf report
