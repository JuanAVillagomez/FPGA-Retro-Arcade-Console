`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTA
// Engineer: Juan A. Villagomez
// 
// Create Date: 08/02/2026 09:07:29 PM
// Design Name: VGA Timing Controller
// Module Name: vga_timing
// Project Name: Retro Arcade
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_timing (
    input wire pixel_clk,   // The 25.175 MHz clock signal
    input wire rst,         // A reset button to restart the screen

    output wire hsync,      // Horizontal Sync pulse to the monitor
    output wire vsync,      // Vertical Sync pulse to the monitor
    output wire video_on,   // High (1) when we are in the visible drawing area, Low (0) during blanking
    
    output wire [9:0] x,    // The current X pixel coordinate (0 to 799)
    output wire [9:0] y     // The current Y pixel coordinate (0 to 524)
);

// 1. VGA 640x480 @ 60Hz Industry Standard Timing Constants
    localparam H_DISPLAY       = 640;
    localparam H_FRONT_PORCH   = 16;
    localparam H_SYNC_PULSE    = 96;
    localparam H_BACK_PORCH    = 48;
    localparam H_TOTAL         = 800; 

    localparam V_DISPLAY       = 480;
    localparam V_FRONT_PORCH   = 10;
    localparam V_SYNC_PULSE    = 2;
    localparam V_BACK_PORCH    = 33;
    localparam V_TOTAL         = 525; 

    // 2. Internal Registers (Memory) for counting pixels
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // 3. The Counter Logic
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            // Horizontal Counter: Count 0 to 799, then reset
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                
                // Vertical Counter: Increments only when a horizontal line finishes
                if (v_count == V_TOTAL - 1) begin
                    v_count <= 0;
                end else begin
                    v_count <= v_count + 1;
                end
            end else begin
                h_count <= h_count + 1; // Keep moving across the screen
            end
        end
    end

    // 4. Output Signal Generation (Combinational Routing)
    // H-Sync and V-Sync are "Active Low" (0) during the sync phase, and 1 otherwise
    assign hsync = ~((h_count >= H_DISPLAY + H_FRONT_PORCH) && (h_count < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE));
    
    assign vsync = ~((v_count >= V_DISPLAY + V_FRONT_PORCH) && (v_count < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE));

    // Video is ON only during the 640x480 active drawing area
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

    // Route our internal counters out of the module
    assign x = h_count;
    assign y = v_count;
endmodule