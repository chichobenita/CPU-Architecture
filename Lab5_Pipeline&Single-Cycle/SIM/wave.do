onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/Jump_addr_i
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/PCBranch_addr_i
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/PCSrc_i
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/pc_o
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/pc_plus4_o
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/instruction_o
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/itcm_addr_w
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/next_pc_w
add wave -noupdate -group Ifetch /mips_tb/CORE/IFE/Stall_IF
add wave -noupdate -group Idecode /mips_tb/CORE/ID/instruction_i
add wave -noupdate -group Idecode /mips_tb/CORE/ID/write_dst_i
add wave -noupdate -group Idecode /mips_tb/CORE/ID/read_data1_o
add wave -noupdate -group Idecode /mips_tb/CORE/ID/read_data2_o
add wave -noupdate -group Idecode /mips_tb/CORE/ID/write_data_o
add wave -noupdate -group Idecode /mips_tb/CORE/ID/RF_q
add wave -noupdate -group Idecode /mips_tb/CORE/ID/rs_register_w
add wave -noupdate -group Idecode /mips_tb/CORE/ID/rt_register_w
add wave -noupdate -group Idecode /mips_tb/CORE/ID/rd_register_w
add wave -noupdate -group control /mips_tb/CORE/CTL/opcode_i
add wave -noupdate -group control /mips_tb/CORE/CTL/RegDst_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/ALUSrc_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/MemtoReg_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/RegWrite_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/MemRead_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/MemWrite_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/Branch_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/Bne_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/Beq_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/Jump_ctrl_o
add wave -noupdate -group control /mips_tb/CORE/CTL/ALUOp_ctrl_o
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/read_data1_i
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/read_data2_i
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/sign_extend_i
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/funct_i
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/ALUOp_ctrl_i
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/ALUSrc_ctrl_i
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/ForwardA_i
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/ForwardB_i
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/alu_res_o
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/WriteData_o
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/a_input_w
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/b_input_w
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/Bforward_mux
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/alu_ctl_w
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/alu_ctl_w1
add wave -noupdate -group Iexecute /mips_tb/CORE/EXE/alu_ctl_w2
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/MemtoReg_EX
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/MemtoReg_MEM
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/WriteReg_EX
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/WriteReg_MEM
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/WriteReg_WB
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/RegRs_ID
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/RegRt_ID
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/RegRs_EX
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/RegRt_EX
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/EX_RegWr
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/MEM_RegWr
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/WB_RegWr
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/BranchBeq_ID
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/BranchBne_ID
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/Stall_IF
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/Stall_ID
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/Flush_EX
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/ForwardA
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/ForwardB
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/ForwardA_Branch
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/ForwardB_Branch
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/load_use_hazard
add wave -noupdate -group Hazard_forward_unit /mips_tb/CORE/Hazard_And_Forward_unit/BranchStall
add wave -noupdate -group clocks /mips_tb/CORE/rst_i
add wave -noupdate -group clocks /mips_tb/CORE/clk_i
add wave -noupdate -group clocks /mips_tb/CORE/FHCNT_o
add wave -noupdate -group clocks /mips_tb/CORE/STCNT_o
add wave -noupdate -group clocks /mips_tb/CORE/STRIGGER_o
add wave -noupdate -group clocks /mips_tb/CORE/CLKCNT_o
add wave -noupdate -group clocks /mips_tb/CORE/inst_cnt_o
add wave -noupdate -group clocks /mips_tb/CORE/Branch_ID
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/IFpc_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/IFinstruction_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/IDpc_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/IDinstruction_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/EXpc_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/EXinstruction_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/MEMpc_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/MEMinstruction_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/WBpc_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/WBinstruction_o
add wave -noupdate -group MIPS_OUTPUTS /mips_tb/CORE/MCLK_w
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 447
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {760 ps}
