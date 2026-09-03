module top_arcade (
    input wire clk_12mhz,   // Physical 12 MHz oscillator clock
    input wire btn_reset,   // Cmod A7 BTN0 button

    // VGA Sync Pins
    output wire vga_hsync,  
    output wire vga_vsync,  
    
    // VGA Color Pins (4 bits per channel = 12-bit color)
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b,
    
    // NES Controller Pins
    input wire nes_data,    
    output wire nes_latch,  
    output wire nes_clk,    
    
    // Onboard LEDs (for button debugging)
    output wire [1:0] led   
);

    // Internal Wires (The PCB traces between our internal FPGA chips)
    wire clk_25mhz;
    wire video_on;
    wire [9:0] x;
    wire [9:0] y;
    wire [7:0] player_buttons;

    // 1. Clock Generator (12 MHz -> 25.175 MHz)
    clk_wiz_0 clock_generator (
        .clk_in1(clk_12mhz), 
        .clk_out1(clk_25mhz) 
    );

    // 2. VGA Timing Engine
    vga_timing display_engine (
        .pixel_clk(clk_25mhz), 
        .rst(btn_reset),
        .hsync(vga_hsync),     
        .vsync(vga_vsync),     
        .video_on(video_on),
        .x(x),
        .y(y)
    );
    
    // 3. NES Controller Engine
    nes_controller pad1 (
        .clk(clk_25mhz),       
        .rst(btn_reset),
        .nes_data(nes_data),
        .nes_latch(nes_latch),
        .nes_clk(nes_clk),
        .buttons(player_buttons)
    );
   

    // 4. Game Brain (Graphics & Physics)
    game_logic game_brain (
        .clk(clk_25mhz),
        .rst(btn_reset),
        .x(x),
        .y(y),
        .video_on(video_on),
        .vsync(vga_vsync),
        .buttons(player_buttons),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

    // 5. LED Debug Routing (A = LD1, B = LD2)
    assign led[0] = player_buttons[0]; 
    assign led[1] = player_buttons[1]; 

endmodule