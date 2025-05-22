onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbcontrol/clk
add wave -noupdate /tbcontrol/rst
add wave -noupdate /tbcontrol/ena
add wave -noupdate /tbcontrol/st
add wave -noupdate /tbcontrol/ld
add wave -noupdate /tbcontrol/mov
add wave -noupdate /tbcontrol/done
add wave -noupdate /tbcontrol/add
add wave -noupdate /tbcontrol/and_o
add wave -noupdate /tbcontrol/or_o
add wave -noupdate /tbcontrol/xor_o
add wave -noupdate /tbcontrol/sub
add wave -noupdate /tbcontrol/jmp
add wave -noupdate /tbcontrol/jc
add wave -noupdate /tbcontrol/jnc
add wave -noupdate /tbcontrol/Cflag
add wave -noupdate /tbcontrol/Zflag
add wave -noupdate /tbcontrol/Nflag
add wave -noupdate /tbcontrol/IRin
add wave -noupdate /tbcontrol/Imm1_in
add wave -noupdate /tbcontrol/Imm2_in
add wave -noupdate /tbcontrol/RFin
add wave -noupdate /tbcontrol/RFout
add wave -noupdate /tbcontrol/PCin
add wave -noupdate /tbcontrol/Ain
add wave -noupdate /tbcontrol/DTCM_wr
add wave -noupdate /tbcontrol/DTCM_out
add wave -noupdate /tbcontrol/DTCM_addr_in
add wave -noupdate /tbcontrol/DTCM_addr_out
add wave -noupdate /tbcontrol/DTCM_addr_sel
add wave -noupdate /tbcontrol/ALFUN
add wave -noupdate /tbcontrol/PCsel
add wave -noupdate /tbcontrol/RFaddr_rd
add wave -noupdate /tbcontrol/RFaddr_wr
add wave -noupdate /tbcontrol/done_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 40
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {5212928 ps}
