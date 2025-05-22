onerror {resume}
add list -width 9 /tb/rst
add list /tb/clk
add list /tb/repeat
add list /tb/upperBound
add list /tb/count
add list /tb/busy
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
