# 12 MHz System Clock
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { clk_12mhz }]; 

# Cmod A7 Built-in Reset Button (BTN0)
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { btn_reset }]; 

# Cmod A7 Built-in LEDs
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; 
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; 

# NES Controller Pins (Moved to KiCad Pins 21, 22, 23)
set_property -dict { PACKAGE_PIN N1    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { nes_data }];  # PIO21
set_property -dict { PACKAGE_PIN N2    IOSTANDARD LVCMOS33 } [get_ports { nes_latch }];               # PIO22
set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports { nes_clk }];                 # PIO23

# VGA Sync Pins (Flipped on KiCad)
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports { vga_hsync }];               # PIO48
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports { vga_vsync }];               # PIO47

# VGA Red Bits (Moved and Bit-Flipped)
set_property -dict { PACKAGE_PIN V4    IOSTANDARD LVCMOS33 } [get_ports { vga_r[3] }];                # PIO37
set_property -dict { PACKAGE_PIN W5    IOSTANDARD LVCMOS33 } [get_ports { vga_r[2] }];                # PIO36
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports { vga_r[1] }];                # PIO35
set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports { vga_r[0] }];                # PIO34

# VGA Green Bits (Moved and Bit-Flipped)
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports { vga_g[3] }];                # PIO33
set_property -dict { PACKAGE_PIN W2    IOSTANDARD LVCMOS33 } [get_ports { vga_g[2] }];                # PIO32
set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports { vga_g[1] }];                # PIO31
set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports { vga_g[0] }];                # PIO30

# VGA Blue Bits (Moved and Bit-Flipped)
set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports { vga_b[3] }];                # PIO29
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports { vga_b[2] }];                # PIO28
set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports { vga_b[1] }];                # PIO27
set_property -dict { PACKAGE_PIN R3    IOSTANDARD LVCMOS33 } [get_ports { vga_b[0] }];                # PIO26