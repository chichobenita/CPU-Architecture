# Define the main clock on clk_i pin
create_clock -name clk_i -period 10.0 [get_ports clk_i]

# Ignore altera_reserved_tck to avoid confusion
set_false_path -from [get_ports altera_reserved_tck]

# Example input and output delays if needed:
# set_input_delay -clock clk_i 2.0 [all_inputs]
# set_output_delay -clock clk_i 2.0 [all_outputs]
