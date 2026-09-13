module decoder
(
    input clk,
    output flash_clk,
    input flash_miso, 
    output flash_mosi,
    output flash_cs,
    input rst,
    input get_data,
    output reg out
);
// There's no "STATE_DONE". You need to stop reading when you're done with the data.
localparam STATE_AWAITING = 2'd0;
localparam STATE_BLACK = 2'd1;
localparam STATE_WHITE = 2'd2;

reg [1:0] state = STATE_AWAITING;
wire [15:0] flash_out;
reg [15:0] buffer = 0;
reg [7:0] count = 0;
reg load_next_word = 0;

flash_reader reader (
.clk(clk),
.flash_clk(flash_clk),
.flash_cs(flash_cs),
.flash_miso(flash_miso),
.flash_mosi(flash_mosi),
.next(load_next_word),
.rst(rst),
.dataReady(flash_ready),
.out(flash_out));

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state<=STATE_AWAITING;
        count<=0;
        out<=0;
    end else begin
        load_next_word<=0;

        // buffer[15:8] is for black pixel count, buffer[7:0] is for white pixel count
        case (state)
            STATE_AWAITING: begin
                if (flash_ready) begin
                    buffer <= flash_out;
                    load_next_word<=1;
                    state<=STATE_BLACK;
                    out<=0;
                    count<=flash_out[15:8];
                end
            end
            
            STATE_BLACK: begin
                if (count==0 & flash_ready) begin
                    state<=STATE_WHITE;
                    out<=1;
                    count<=buffer[7:0];
                    buffer <= flash_out;
                    load_next_word<=1;
                end
                else if (get_data) begin
                    count<=count-1'd1;
                end
            end

            STATE_WHITE: begin
                if (count==0) begin
                    state<=STATE_BLACK;
                    out<=0;
                    count<=buffer[15:8];
                end
                else if (get_data) begin
                    count<=count-8'b1;
                end
            end
        endcase
    end
end
endmodule