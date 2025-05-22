onerror {resume}
add list -width 16 /datapth_tb/st
add list /datapth_tb/ld
add list /datapth_tb/mov
add list /datapth_tb/done
add list /datapth_tb/add
add list /datapth_tb/sub
add list /datapth_tb/jmp
add list /datapth_tb/jc
add list /datapth_tb/jnc
add list /datapth_tb/xor_o
add list /datapth_tb/or_o
add list /datapth_tb/and_o
add list /datapth_tb/Cflag
add list /datapth_tb/Zflag
add list /datapth_tb/Nflag
add list /datapth_tb/IRin
add list /datapth_tb/Imm1_in
add list /datapth_tb/Imm2_in
add list /datapth_tb/RFin
add list /datapth_tb/RFout
add list /datapth_tb/PCin
add list /datapth_tb/Ain
add list /datapth_tb/DTCM_wr
add list /datapth_tb/DTCM_out
add list /datapth_tb/DTCM_addr_in
add list /datapth_tb/DTCM_addr_out
add list /datapth_tb/DTCM_addr_sel
add list /datapth_tb/ALFUN
add list /datapth_tb/PCsel
add list /datapth_tb/RFaddr_rd
add list /datapth_tb/RFaddr_wr
add list /datapth_tb/done_FSM
add list /datapth_tb/TBactive
add list /datapth_tb/clk
add list /datapth_tb/rst
add list /datapth_tb/ITCM_tb_wr
add list /datapth_tb/DTCM_tb_wr
add list /datapth_tb/DTCM_tb_in
add list /datapth_tb/ITCM_tb_in
add list /datapth_tb/ITCM_tb_addr_in
add list /datapth_tb/DTCM_tb_addr_in
add list /datapth_tb/DTCM_tb_addr_out
add list /datapth_tb/DTCM_tb_out
add list /datapth_tb/donePmemIn
add list /datapth_tb/doneDmemIn
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
