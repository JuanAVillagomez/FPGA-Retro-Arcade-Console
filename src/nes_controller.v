module nes_controller (
    input wire clk,          // The main system clock
    input wire rst,          // System reset
    input wire nes_data,     // The serial data coming IN from the NES controller

    output reg nes_latch,    // The latch pulse going OUT to the controller
    output reg nes_clk,      // The clock pulse going OUT to the controller
    
    output reg [7:0] buttons // The 8-bit register storing our button states
);

// 1. Clock Divider (Slow the 25.175 MHz down to ~100 kHz)
    // 100 kHz = a period of 10 microseconds. We toggle every 5 us.
    // 25.175 MHz = ~39.7 ns per tick. 5 us / 39.7 ns = ~126 ticks.
    reg [7:0] clk_counter = 0;
    reg clk_100k = 0;

    always @(posedge clk) begin
        if (clk_counter >= 125) begin
            clk_counter <= 0;
            clk_100k <= ~clk_100k;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end

    // 2. The Finite State Machine
    // Using simple states to walk through the NES communication protocol
    reg [4:0] state = 0;
    reg [7:0] shift_reg = 0;

    always @(posedge clk_100k or posedge rst) begin
        if (rst) begin
            state <= 0;
            nes_latch <= 0;
            nes_clk <= 0;
            buttons <= 8'b00000000;
        end else begin
            case (state)
                // STATE 0: Send the Latch Pulse (Tells controller to lock button states)
                0: begin
                    nes_latch <= 1;
                    nes_clk <= 0;
                    state <= 1;
                end
                
                // STATE 1: End Latch Pulse, prepare to read Button 0 (A)
                1: begin
                    nes_latch <= 0;
                    state <= 2;
                end
                
                // STATES 2-17: The Clocking Loop (8 pulses)
                // Even states: Clock is LOW, we sample the data line
                // Odd states: Clock is HIGH
                2, 4, 6, 8, 10, 12, 14, 16: begin
                    nes_clk <= 0;
                    // Read the incoming bit and shift it into our register
                    // Note: The NES controller is Active Low (0 = button pressed)
                    // We invert it with ~ so 1 = pressed in our game logic.
                    shift_reg <= {shift_reg[6:0], ~nes_data};
                    state <= state + 1;
                end
                
                3, 5, 7, 9, 11, 13, 15, 17: begin
                    nes_clk <= 1;
                    state <= state + 1;
                end
                
                // STATE 18: Latch the final button values into output register
                18: begin
                    buttons <= shift_reg;
                    state <= 19;
                end
                
                // STATE 19: Delay before next read
                19: begin
                    // In a real system you'd delay ~16ms here so you only poll once per frame,
                    // but for simplicity, we will just start polling again immediately.
                    state <= 0; 
                end
                
                default: state <= 0;
            endcase
        end
    end
endmodule