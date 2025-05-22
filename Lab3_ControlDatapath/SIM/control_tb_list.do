onerror {resume}
add list -width 16 /tbcontrol/clk
add list /tbcontrol/rst
add list /tbcontrol/ena
add list /tbcontrol/st
add list /tbcontrol/ld
add list /tbcontrol/mov
add list /tbcontrol/done
add list /tbcontrol/add
add list /tbcontrol/and_o
add list /tbcontrol/or_o
add list /tbcontrol/xor_o
add list /tbcontrol/sub
add list /tbcontrol/jmp
add list /tbcontrol/jc
add list /tbcontrol/jnc
add list /tbcontrol/Cflag
add list /tbcontrol/Zflag
add list /tbcontrol/Nflag
add list /tbcontrol/IRin
add list /tbcontrol/Imm1_in
add list /tbcontrol/Imm2_in
add list /tbcontrol/RFin
add list /tbcontrol/RFout
add list /tbcontrol/PCin
add list /tbcontrol/Ain
add list /tbcontrol/DTCM_wr
add list /tbcontrol/DTCM_out
add list /tbcontrol/DTCM_addr_in
add list /tbcontrol/DTCM_addr_out
add list /tbcontrol/DTCM_addr_sel
add list /tbcontrol/ALFUN
add list /tbcontrol/PCsel
add list /tbcontrol/RFaddr_rd
add list /tbcontrol/RFaddr_wr
add list /tbcontrol/done_o
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
