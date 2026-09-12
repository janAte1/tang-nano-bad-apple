// Based on:
// 1.14 inch 240x135 SPI LCD TEST for TANG NANO 9K
// by fanoble, QQ:87430545
// 27/6/2022

module top(
	input clk, // 27MHz

	output lcd_resetn,
	output lcd_clk,
	output lcd_cs,
	output lcd_rs,
	output lcd_data,

    output flashClk,
    input flashMiso, 
    output flashMosi,
    output flashCs,

    output buzzer_pin,

    input btn1,
    input btn2,
    input btn3
);
debouncer dbc2 (.clk(clk), .btn(~btn2), .out(pause_button));
debouncer dbc3 (.clk(clk), .btn(~btn3), .out(mute_button));
reg muted = 0;
reg paused = 0;

wire rst = ~btn1;

localparam TOTAL_FRAMES = 6955;
localparam MAX_CMDS = 69;
localparam MELODY_START_TIMESTAMP = 29*30; // melody starts at 27s, timestamp measured in frames

wire [8:0] init_cmd[MAX_CMDS:0];

// --- Memory Access Control & Pixel Format ---
assign init_cmd[ 0] = 9'h036; // Cmd  0x36: MADCTL (Memory Data Access Control)
assign init_cmd[ 1] = 9'h170; // Data 0x70: Set Landscape orientation & RGB color order

assign init_cmd[ 2] = 9'h03A; // Cmd  0x3A: COLMOD (Interface Pixel Format)
assign init_cmd[ 3] = 9'h105; // Data 0x05: Set 16 bits per pixel (RGB565)

// --- Frame Rate & Internal Voltages ---
assign init_cmd[ 4] = 9'h0B2; // Cmd  0xB2: PORCTRL (Porch Setting)
assign init_cmd[ 5] = 9'h10C; // Data 0x0C: Back porch in normal mode
assign init_cmd[ 6] = 9'h10C; // Data 0x0C: Front porch in normal mode
assign init_cmd[ 7] = 9'h100; // Data 0x00: Separate porch enable
assign init_cmd[ 8] = 9'h133; // Data 0x33: Back/Front porch in idle mode
assign init_cmd[ 9] = 9'h133; // Data 0x33: Back/Front porch in sleep mode

assign init_cmd[10] = 9'h0B7; // Cmd  0xB7: GCTRL (Gate Control)
assign init_cmd[11] = 9'h135; // Data 0x35: Set VGH/VGL gate drive voltages

assign init_cmd[12] = 9'h0BB; // Cmd  0xBB: VCOMS (VCOM Setting)
assign init_cmd[13] = 9'h119; // Data 0x19: Set VCOM voltage (~0.725V)

assign init_cmd[14] = 9'h0C0; // Cmd  0xC0: LCMCTRL (LCM Power Control)
assign init_cmd[15] = 9'h12C; // Data 0x2C: Default panel driving settings

assign init_cmd[16] = 9'h0C2; // Cmd  0xC2: VDVVRHEN (VDV / VRH Command Enable)
assign init_cmd[17] = 9'h101; // Data 0x01: Enable custom VDV/VRH register values

assign init_cmd[18] = 9'h0C3; // Cmd  0xC3: VRHS (VRH Voltage Set)
assign init_cmd[19] = 9'h112; // Data 0x12: Set positive/negative gamma supply voltages

assign init_cmd[20] = 9'h0C4; // Cmd  0xC4: VDVS (VDV Voltage Set)
assign init_cmd[21] = 9'h120; // Data 0x20: Set VDV voltage level

assign init_cmd[22] = 9'h0C6; // Cmd  0xC6: FRCTRL2 (Frame Rate Control)
assign init_cmd[23] = 9'h10F; // Data 0x0F: Set refresh rate to 60 Hz

assign init_cmd[24] = 9'h0D0; // Cmd  0xD0: PWCTRL1 (Power Control 1)
assign init_cmd[25] = 9'h1A4; // Data 0xA4: Set AVDD/AVCL power supply parameters
assign init_cmd[26] = 9'h1A1; // Data 0xA1: Enable internal power step-up circuits

// --- Gamma Curves Correction (30 bytes) ---
assign init_cmd[27] = 9'h0E0; // Cmd  0xE0: PVGAMCTRL (Positive Voltage Gamma Control)
assign init_cmd[28] = 9'h1D0; // Gamma curve definition parameters (curve adjustment)
assign init_cmd[29] = 9'h104;
assign init_cmd[30] = 9'h10D;
assign init_cmd[31] = 9'h111;
assign init_cmd[32] = 9'h113;
assign init_cmd[33] = 9'h12B;
assign init_cmd[34] = 9'h13F;
assign init_cmd[35] = 9'h154;
assign init_cmd[36] = 9'h14C;
assign init_cmd[37] = 9'h118;
assign init_cmd[38] = 9'h10D;
assign init_cmd[39] = 9'h10B;
assign init_cmd[40] = 9'h11F;
assign init_cmd[41] = 9'h123;

assign init_cmd[42] = 9'h0E1; // Cmd  0xE1: NVGAMCTRL (Negative Voltage Gamma Control)
assign init_cmd[43] = 9'h1D0; // Gamma curve definition parameters (curve adjustment)
assign init_cmd[44] = 9'h104;
assign init_cmd[45] = 9'h10C;
assign init_cmd[46] = 9'h111;
assign init_cmd[47] = 9'h113;
assign init_cmd[48] = 9'h12C;
assign init_cmd[49] = 9'h13F;
assign init_cmd[50] = 9'h144;
assign init_cmd[51] = 9'h151;
assign init_cmd[52] = 9'h12F;
assign init_cmd[53] = 9'h11F;
assign init_cmd[54] = 9'h11F;
assign init_cmd[55] = 9'h120;
assign init_cmd[56] = 9 'h123;

// --- Display On & Active Window Setup ---
assign init_cmd[57] = 9'h021; // Cmd  0x21: INVON (Display Inversion ON - needed for IPS panel color fidelity)
assign init_cmd[58] = 9'h029; // Cmd  0x29: DISPON (Turn Display Output On)

assign init_cmd[59] = 9'h02A; // Cmd  0x2A: CASET (Column Address Set)
assign init_cmd[60] = 9'h100; // Data Start Col MSB = 0x00
assign init_cmd[61] = 9'h128; // Data Start Col LSB = 0x28 (Column 40)
assign init_cmd[62] = 9'h100; // Data End Col MSB   = 0x01
assign init_cmd[63] = 9'h1db; // Data End Col LSB   = 0x17 (Column 219)

assign init_cmd[64] = 9'h02B; // Cmd  0x2B: RASET (Row Address Set)
assign init_cmd[65] = 9'h100; // Data Start Row MSB = 0x00
assign init_cmd[66] = 9'h135; // Data Start Row LSB = 0x35 (Row 53)
assign init_cmd[67] = 9'h100; // Data End Row MSB   = 0x00
assign init_cmd[68] = 9'h1BB; // Data End Row LSB   = 0xBB (Row 187)

assign init_cmd[69] = 9'h02C; // Cmd  0x2C: RAMWR (Memory Write - prepares controller to accept streaming RGB pixels)

localparam INIT_RESET   = 4'b0000; // delay 100ms while reset
localparam INIT_PREPARE = 4'b0001; // delay 200ms after reset
localparam INIT_WAKEUP  = 4'b0010; // write cmd 0x11 MIPI_DCS_EXIT_SLEEP_MODE
localparam INIT_SNOOZE  = 4'b0011; // delay 120ms after wakeup
localparam INIT_WORKING = 4'b0100; // write command & data
localparam PLAYBACK    = 4'b0101; // 
localparam WAITING_FOR_NEXT_FRAME = 4'b0110;

localparam CNT_100MS = 32'd2700000;
localparam CNT_120MS = 32'd3240000;
localparam CNT_200MS = 32'd5400000;
localparam CNT_30FPS = 32'd900000;

reg [ 3:0] state;
reg [ 6:0] cmd_index;
reg [31:0] clk_cnt;
reg [ 4:0] bit_loop;

reg [15:0] pixel_cnt;
reg [15:0] frame_cnt;

reg lcd_cs_r;
reg lcd_rs_r;
reg lcd_reset_r;

reg [7:0] spi_data;

assign lcd_resetn = lcd_reset_r;
assign lcd_clk    = ~clk;
assign lcd_cs     = lcd_cs_r;
assign lcd_rs     = lcd_rs_r;
assign lcd_data   = spi_data[7]; // MSB

reg [15:0] pixel;

reg decoder_get_data = 0;
wire decoder_out;

decoder dcd (
.clk(clk),
.flashClk(flashClk),
.flashMiso(flashMiso),
.flashMosi(flashMosi),
.flashCs(flashCs),
.rst(rst),
.get_data(decoder_get_data),
.out(decoder_out));

reg buzzer_start = 0;
buzzer bzz(
.clk(clk),
.rst(rst),
.start(buzzer_start),
.paused(paused),
.muted(muted),
.out(buzzer_pin));

always@(posedge clk or posedge rst) begin
	if (rst) begin
		clk_cnt <= 0;
		cmd_index <= 0;
		state <= INIT_RESET;

		lcd_cs_r <= 1;
		lcd_rs_r <= 1;
		lcd_reset_r <= 0;
		spi_data <= 8'hFF;
		bit_loop <= 0;

		pixel_cnt <= 0;
        frame_cnt <=0;
	end else if (mute_button) muted<=~muted;
    else if (pause_button) paused<=~paused;
    else begin
		case (state)
			INIT_RESET : begin
				if (clk_cnt == CNT_100MS) begin
					clk_cnt <= 0;
					state <= INIT_PREPARE;
					lcd_reset_r <= 1;
				end else begin
					clk_cnt <= clk_cnt + 1;
				end
			end

			INIT_PREPARE : begin
				if (clk_cnt == CNT_200MS) begin
					clk_cnt <= 0;
					state <= INIT_WAKEUP;
				end else begin
					clk_cnt <= clk_cnt + 1;
				end
			end

			INIT_WAKEUP : begin
				if (bit_loop == 0) begin
					// start
					lcd_cs_r <= 0;
					lcd_rs_r <= 0;
					spi_data <= 8'h11; // exit sleep
					bit_loop <= bit_loop + 1;
				end else if (bit_loop == 8) begin
					// end
					lcd_cs_r <= 1;
					lcd_rs_r <= 1;
					bit_loop <= 0;
					state <= INIT_SNOOZE;
				end else begin
					// loop
					spi_data <= { spi_data[6:0], 1'b1 };
					bit_loop <= bit_loop + 1;
				end
			end

			INIT_SNOOZE : begin
				if (clk_cnt == CNT_120MS) begin
					clk_cnt <= 0;
					state <= INIT_WORKING;
				end else begin
					clk_cnt <= clk_cnt + 1;
				end
			end

			INIT_WORKING : begin
				if (cmd_index == MAX_CMDS + 1) begin
					state <= PLAYBACK;
                    clk_cnt <= 0;
				end else begin
					if (bit_loop == 0) begin
						// start
						lcd_cs_r <= 0;
						lcd_rs_r <= init_cmd[cmd_index][8];
						spi_data <= init_cmd[cmd_index][7:0];
						bit_loop <= bit_loop + 1;
					end else if (bit_loop == 8) begin
						// end
						lcd_cs_r <= 1;
						lcd_rs_r <= 1;
						bit_loop <= 0;
						cmd_index <= cmd_index + 1; // next command
					end else begin
						// loop
						spi_data <= { spi_data[6:0], 1'b1 };
						bit_loop <= bit_loop + 1;
					end
				end
			end

			PLAYBACK : begin
                buzzer_start <= 0;
                clk_cnt<=clk_cnt+1;
				if (pixel_cnt == 135*180) begin
                    frame_cnt<=frame_cnt+1;
                    pixel_cnt<=0;
                    state<=WAITING_FOR_NEXT_FRAME;
                    if (frame_cnt==MELODY_START_TIMESTAMP) buzzer_start<=1;
				end else begin
                    decoder_get_data<=0;
					if (bit_loop == 0) begin
                        decoder_get_data<=1;
						lcd_cs_r <= 0;
						lcd_rs_r <= 1;
						spi_data[7] <= decoder_out;
						bit_loop <= bit_loop + 1;
					end else if (bit_loop == 16) begin
						lcd_cs_r <= 1;
						lcd_rs_r <= 1;
						bit_loop <= 0;
						pixel_cnt <= pixel_cnt + 1;
					end else begin
						bit_loop <= bit_loop + 1;
					end
				end
			end
            WAITING_FOR_NEXT_FRAME: begin
                if (clk_cnt==CNT_30FPS && frame_cnt!=TOTAL_FRAMES) begin
                    state<=PLAYBACK;
                    clk_cnt<=0;
                end
                else if (~paused) clk_cnt<=clk_cnt+1;
            end
		endcase
	end
end

endmodule