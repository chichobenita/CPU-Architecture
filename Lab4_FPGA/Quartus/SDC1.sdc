# Constrain clock port CLK_50MHz with a 20-ns requirement
create_clock -name CLK_50MHz -period 20.0 [get_ports {*CLK_50MHz}]

# Derive PLL-generated clocks (safe even if unused)
derive_pll_clocks

# Optional: Uncomment and tune these only if needed
# set_input_delay -clock CLK_50MHz -max 3 [all_inputs]
# set_input_delay -clock CLK_50MHz -min 2 [all_inputs]
# set_output_delay -clock CLK_50MHz 2 [all_outputs]
