# CPU Architecture – Project Repository

This repository collects all of our HDL design and verification projects for the **CPU Architecture** course, from the first lab through the final FPGA-based MCU project.

---

## Project Purpose & Objectives

We will develop a deep understanding of:

1. **Hardware Description Languages (HDL)**  
   – Functional verification, simulation and synthesis flows  
2. **Digital System Design**  
   – Combinational, clocked-synchronous and mixed-signal design  
3. **FPGA Design Flow**  
   – Functional verification → timing & resource validation on an FPGA  
4. **Microarchitecture & ISA**  
   – Separation of Control vs. Datapath in a multi-cycle CPU  
5. **Pipelined MIPS Processor**  
   – Single-thread, N-stage pipeline implementation  
6. **Final MCU Project**  
   – Integrate a MIPS core with peripherals and hardware accelerators on an FPGA  

---

## Repository Structure

```text
CPU-Architecture/
├── Lab1_Concurrent/       # VHDL concurrent code: structural ALU design & test benches
├── Lab2_Sequential/       # VHDL sequential code: behavioral counter & dynamic bound
├── Lab3_ControlDatapath/  # Multi-cycle RISC CPU: Control FSM & Datapath integration
├── Lab4_Pipelined/        # Pipelined MIPS core, N-stage pipeline implementation
├── Final_MCU/             # FPGA-based MCU: MIPS core + peripheral modules & accelerators
└── README.md              # This overview file
