create_clock -name clock -period 37.037 -waveform {0 18.518} [get_ports {clk}]
create_generated_clock -name lcd_clock -source [get_ports {clk}] -invert [get_ports {lcd_clk}]
create_generated_clock -name flash_clock -source [get_ports {clk}] -invert [get_ports {flashClk}]
