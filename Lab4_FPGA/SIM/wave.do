onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top_digit_sys/clk
add wave -noupdate /tb_top_digit_sys/ENA
add wave -noupdate /tb_top_digit_sys/rst
add wave -noupdate /tb_top_digit_sys/X_i
add wave -noupdate /tb_top_digit_sys/Y_i
add wave -noupdate /tb_top_digit_sys/ALUFN_i
add wave -noupdate /tb_top_digit_sys/ALUout_o
add wave -noupdate /tb_top_digit_sys/Nflag_o
add wave -noupdate /tb_top_digit_sys/Cflag_o
add wave -noupdate /tb_top_digit_sys/Zflag_o
add wave -noupdate /tb_top_digit_sys/Vflag_o
add wave -noupdate /tb_top_digit_sys/PWM_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {115042 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 187
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
WaveRestoreZoom {0 ps} {2001224 ps}
