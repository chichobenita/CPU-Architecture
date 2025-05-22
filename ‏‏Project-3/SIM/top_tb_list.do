onerror {resume}
add list -width 16 /top_tb/done_o
add list /top_tb/rst
add list /top_tb/ena
add list /top_tb/clk
add list /top_tb/TBactive
add list /top_tb/DTCM_tb_wr
add list /top_tb/ITCM_tb_wr
add list /top_tb/DTCM_tb_in
add list /top_tb/DTCM_tb_out
add list /top_tb/ITCM_tb_in
add list /top_tb/DTCM_tb_addr_in
add list /top_tb/ITCM_tb_addr_in
add list /top_tb/DTCM_tb_addr_out
add list /top_tb/donePmemIn
add list /top_tb/doneDmemIn
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
