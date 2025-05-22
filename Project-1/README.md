# CPU Architecture LAB1 – VHDL Part 1: Concurrent Code
## Overview

In LAB1 of our CPU Architecture course, we will design and verify a parameterizable arithmetic-logic unit (ALU) composed of:

- **Generic Adder/Subtractor**: a ripple-carry adder built structurally  
- **Barrel Shifter**: an n-bit shifter implemented using `generate` loops  
- **Boolean Logic Unit**: bitwise NOT, AND, OR and XOR operations  
- **Top-Level Integration**: assembling all submodules into the `top.vhd` entity  

The ALU supports:
- **Arithmetic**: add, subtract, increment, decrement  
- **Shift**: logical left/right by k bits  
- **Logic**: bitwise operations  
- **Status Flags**: Z (zero), C (carry), N (negative), V (overflow)  

## Repository Structure

```text
VHDL-Project-1/         # root directory
├── DUT/                # our VHDL source files (entities & architectures)
├── TB/                 # test benches for each module
├── SIM/                # simulation scripts (.do) & waveform lists (.lst)
├── DOC/                # block diagrams, annotated waveforms & lab report
├── .gitignore          # ignore patterns for build & simulation artifacts
└── README.md           # this document

## Getting Started

### Prerequisites

We assume you have installed:
- **ModelSim** (or another VHDL simulator)  
- **TextDiff** (optional, for comparing waveform lists)

### 1. Compile Design & Test Benches

We compile all VHDL sources and test benches with:
```tcl
vlib work
vcom -2008 DUT/*.vhd TB/*.vhd

vsim work.adder_tb   -do SIM/adder.do
vsim work.shifter_tb -do SIM/shifter.do
vsim work.logic_tb   -do SIM/logic.do

vsim work.top_tb -do SIM/system.do

TextDiff.exe TB/tb_ref1.lst SIM/system.lst

