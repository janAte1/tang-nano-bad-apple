module buzzer
(
    input clk,
    input rst,
    input start,
    input paused,
    input muted,
    output out
);

Gowin_pROM your_instance_name(
    .dout(ram_data), //output [47:0] dout
    .clk(clk), //input clk
    .oce(1), //input oce
    .ce(1), //input ce
    .reset(0), //input reset
    .ad(address) //input [10:0] ad
);
localparam NUM_NOTES = 1632;
reg [10:0] address = 0;
wire [47:0] ram_data;
wire [31:0] duration = ram_data[47:16];
wire [15:0] period = ram_data[15:0];
reg [31:0] time_counter = 0;
reg [31:0] tone_counter = 0;
reg buzzer_out;
assign out = buzzer_out & ~muted;

localparam STATE_WAITING = 1'b0;
localparam STATE_PLAYING = 1'b1;
reg state = STATE_WAITING;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state<=STATE_WAITING;
    end else begin
        case (state)
            STATE_WAITING: begin
                tone_counter <=0;
                time_counter<=0;
                address<=0;
                if (start) state<=STATE_PLAYING;
            end
            
            STATE_PLAYING: begin
                if (tone_counter>=period && period != 0) begin
                    buzzer_out<=~buzzer_out;
                    tone_counter<=0;
                end else if (time_counter == duration) begin
                    if (address==NUM_NOTES) state<=STATE_WAITING;
                    else begin
                        address<=address+1;
                        time_counter<=0;
                    end
                end else if (~paused) begin
                    time_counter<=time_counter+1;
                    tone_counter<=tone_counter+1;
                end
            end
        endcase
    end
end

endmodule