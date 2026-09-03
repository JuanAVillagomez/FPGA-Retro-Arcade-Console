module game_logic (
    input wire clk,
    input wire rst,
    input wire [9:0] x,
    input wire [9:0] y,
    input wire video_on,
    input wire vsync,
    input wire [7:0] buttons,
    
    output reg [3:0] vga_r,
    output reg [3:0] vga_g,
    output reg [3:0] vga_b
);

	//1. State machine defs.
	localparam TITLE = 2'b00;
	localparam PLAY = 2'b01;
	localparam GAMEOVER = 2'b10;
	
	reg [1:0] game_state = TITLE;	//Boots directly to title screen

    //2. Sprite Parameters
    parameter SPRITE_SIZE = 16;
    reg [9:0] sq_x = 312; //Start at x center (640/2 - 8)
    reg [9:0] sq_y = 232; //Center (480/2 - 8)
    
    //Lasers defs
    parameter LASER_W = 2;	//2 pixels wide
    parameter LASER_H = 8;	//8 pixels tall
    reg [9:0] laser_x = 0;
    reg [9:0] laser_y = 0;
    reg laser_active = 0;	//0 = despawned, 1 = fired
    
    //Target defs
    parameter TARGET_SIZE = 16;
    reg [9:0] target_x = 312;
    reg [9:0] target_y = 50;	//Near top of screen
    reg target_active = 1; //Target starts alive
    reg target_dir = 1;		//1 = move right, 0 = move left
    
    //3. Hardware Comparator (collsion detection)
    // Pure combinational logic. Always evaluating. 
    // 1 = active laser overlaps active target
    wire collision = (laser_active && target_active && (laser_x + LASER_W > target_x) && (laser_x < target_x + TARGET_SIZE) && (laser_y < target_y + TARGET_SIZE) && (laser_y + LASER_H > target_y));
    
    //4. Master game loop (locked to 60hz)
    reg vsync_prev;
    reg start_btn_prev;
    reg select_btn_prev;
    reg a_btn_prev; //Track 'A' button (bit 0)
    
    always @(posedge clk) begin
        vsync_prev <= vsync;
        if (vsync_prev == 1 && vsync == 0) begin	
        	//Track prev state of button for Edge Dectection
        	start_btn_prev <= buttons[3];
        	select_btn_prev <= buttons[2];
        	a_btn_prev <= buttons[0];
        	
        	//Make single-pulse triggers for when a btn is newly pressed (1 = current, 0 = prev)
        	if (buttons[3] == 1 && start_btn_prev ==0) begin
        		//Start button logic
        		if (game_state == TITLE) begin
        			game_state <= PLAY;		//Start game
        			sq_x <= 312;	//Start ship x positon
        			sq_y <= 232;	//Start ship y positon
        			target_active <= 1;		//Respawn target
        			laser_active <= 0;		//Clear old lasers
        		end else if (game_state == GAMEOVER) begin
        			game_state <= TITLE;	
        		end
        	end
        	
        	if (buttons[2] == 1 && select_btn_prev == 0) begin
        		//Select button logic (temp gameover for testing!!!)
        		if (game_state == PLAY) game_state <= GAMEOVER;
        	end
        	
        	//Gameplay logic
        	if (game_state == PLAY) begin
        	
        		//Ship movement
        		if (buttons[4] && sq_y > 0) sq_y <= sq_y - 2;
        		if (buttons[5] && (sq_y + SPRITE_SIZE) < 480) sq_y <= sq_y + 2;
        		if (buttons[6] && sq_x > 0) sq_x <= sq_x - 2;
        		if (buttons[7] && (sq_x + SPRITE_SIZE) < 640) sq_x <= sq_x + 2;
        		
        		//Fire laser (Press 'A' when laser not already active)
        		if (buttons[0] == 1 && a_btn_prev == 0 && !laser_active) begin
        			laser_active <= 1;
        			//Center laster on nose of spaceship
        			laser_x <= sq_x + (SPRITE_SIZE/2) - (LASER_W/2);
        			laser_y <= sq_y;
        		end
        		
        		//Laser movement (Flies up 4 pixels per frame)
        		if (laser_active) begin
        			if (laser_y > 4) begin
        				laser_y <= laser_y - 4;
        			end else begin
        				laser_active <= 0; //Hits top of screen = despawn
        			end
        		end
        		
        		//Target movement
        		if (target_active) begin
        			if (target_dir == 1) begin
        				//Move right
        				if (target_x + TARGET_SIZE < 640) begin
        					target_x <= target_x + 2;
        				end else begin
        					target_dir <= 0; //Hit right wall, flip switch to left
        				end
        			end else begin
        				//Move left
        				if (target_x > 0) begin
        					target_x <= target_x - 2;
        				end else begin
        					target_dir <= 1;	//Hit left wall, flip switch to right
        				end
        			end
        		end
        		
        		//Collision handling
        		if (collision) begin
        			target_active <= 0; //Destroy target
        			laser_active <= 0;	//Destroy laser
        		end
        	end
        end
	end       
    
    //5. Memory address calculation
    //Find our local coords (0 to 15) inside spaceship boundaries
    
    wire [3:0] sprite_x = x - sq_x;
    wire [3:0] sprite_y = y - sq_y;
    
    //Combine y and x to create a 0-255 mem address
    wire [7:0] rom_addr = {sprite_y, sprite_x};
    
    //6. ROM instantiation (pluggins into mem chip)
    wire [11:0] sprite_data;	//Wire catches 12-bit hex color from the ROM 
    blk_mem_gen_0 sprite_rom (
		.clka(clk),
		.addra(rom_addr),
		.douta(sprite_data)
    );
    
    //7. Pipeling (1-clock delay)
    reg draw_sprite;
    always @(posedge clk) begin
    	//Check if the VGA gun is inside the sprite bounds THIS clock cycle
    	if ((x >= sq_x) && (x < sq_x + SPRITE_SIZE) && (y >= sq_y) && (y < sq_y + SPRITE_SIZE)) begin
    		draw_sprite <= 1; //It becomes '1' on NEXT clock cycle
    	end else begin
    		draw_sprite <= 0;
    	end
    end

	//8. Rendering logic (painting the pixels)
	always @(posedge clk) begin
		//Default background color is black
		vga_r <= 4'b0000;
		vga_g <= 4'b0000;
		vga_b <= 4'b0000;
		
		if (video_on) begin
			case (game_state)
				TITLE: begin	//Render Blue background for title screen
					vga_r <= 4'b0000;
					vga_g <= 4'b0000;
					vga_b <= 4'b1111;
				end
				
				PLAY: begin
					//Render layer 1: the target (green square)
					if (target_active && (x >= target_x) && (x < target_x + TARGET_SIZE) && (y >= target_y) && (y < target_y + TARGET_SIZE)) begin
						vga_g <= 4'b1111;
					end
					//Render layer 2: the laser (yellow rectangle)
					else if (laser_active && (x >= laser_x) && (x < laser_x + LASER_W) && (y >= laser_y) && (y < laser_y + LASER_H)) begin
						vga_r <= 4'b1111;
						vga_g <= 4'b1111;
					end
					//Render layer 3: black bg of space and spaceship sprite
					//We use 'draw_sprite' which is delayed by 1 clock cycle, matching 1-clock delay of 'sprite_data' coming from ROM
					// Also check if sprite_data != 12'h000 (black)
					else if (draw_sprite && sprite_data != 12'h000) begin
						vga_r <= sprite_data [11:8]; //top 4 are red
						vga_g <= sprite_data [7:4]; //middle 4 are green
						vga_b <= sprite_data [3:0]; // bottom 4 are blue
					end
				end
				
				GAMEOVER: begin
					//Render red bg
					vga_r <= 4'b1111;
					vga_g <= 4'b0000;
					vga_b <= 4'b0000;
				end
			endcase
		end 
	end

endmodule