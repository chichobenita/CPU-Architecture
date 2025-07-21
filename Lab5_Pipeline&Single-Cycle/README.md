# CPU Architecture LAB5 – Single-Cycle & Scalar Pipelined MIPS CPU

## Overview
In Lab 5 we evolve a single‑cycle MIPS-compatible CPU into a five‑stage pipelined CPU with hazard detection and data forwarding, then analyze and verify performance both functionally and in hardware.

Key objectives:
- **Single‑Cycle Baseline**: Validate the combinational MIPS datapath in one clock cycle per instruction.
- **Five‑Stage Pipeline**: Implement IF, ID, EX, MEM, and WB stages with data hazard detection and forwarding, plus a single delay slot for branches.
- **Performance Analysis**: Use Timing Analyzer to determine fₘₐₓ, identify critical/shortest paths, and compute IPC/CPI metrics via STCNT_o, FHCNT_o and CLKCNT_o.
- **Hardware Verification**: Simulate in ModelSim for coverage, and use SignalTap on DE10-Standard to capture internal pipeline signals.
- **QA Tests**: Create and run assembly tests (clauses 8d & 8e) in MARS to compare measured IPC against theoretical values.

## Repository Structure
```text
Lab5_pipeline&Single-Cycle/
├── VHDL_Project/    # Synthesizable VHDL: single-cycle and pipelined CPU sources
├── TB/              # Single top‑level test bench (tb.vhd) for full‑system verification
├── SIM/             # ModelSim scripts (.do) for compile, elaborate & simulate
├── Quartus/         # Quartus project (.qpf, .qsf, .sdc, .sof) & pin assignments
├── SignalTap/       # SignalTap project & capture files (.stp, .stpdb)
├── CODE/            # Assembly source code for QA tests (clauses 8d & 8e)
└── DOC/             # Documentation: Lab5.pdf full report & supplementary diagrams
