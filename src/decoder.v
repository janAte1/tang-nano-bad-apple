module decoder
(
    input clk,
    output flashClk,
    input flashMiso, 
    output flashMosi,
    output flashCs,
    input rst,  // asynchronous signal to return to starting address,
    input get_data,
    output reg out
);

flashReader #(24'h10_00_00) reader (
.clk(clk),
.flashClk(flashClk),
.flashCs(flashCs),
.flashMiso(flashMiso),
.flashMosi(flashMosi),
.next(load_next_word),
.rst(rst),
.dataReady(flash_ready),
.out(flash_out));

localparam STATE_AWAITING = 2'd0;
localparam STATE_BLACK = 2'd1;
localparam STATE_WHITE = 2'd2;
localparam STATE_DONE = 2'd3;
reg [1:0] state = STATE_AWAITING;
wire [15:0] flash_out;
reg [15:0] buffer = 0;
reg [7:0] count = 0;
reg load_next_word = 0;

always @(posedge clk or posedge rst) begin
if (rst) begin
    state<=STATE_AWAITING;
    count<=0;
    out<=0;
end else begin
load_next_word<=0;

// [15:8] is black, [7:0] is white
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
        if (count==0) begin
            state<=STATE_WHITE;
            out<=1;
            count<=buffer[7:0];
            buffer <= flash_out;
            load_next_word<=1;
            if (~flash_ready) state<=STATE_DONE;
        end
        else if (get_data) begin
            count<=count-1;
        end
    end

    STATE_WHITE: begin
        if (count==0) begin
            state<=STATE_BLACK;
            out<=0;
            count<=buffer[15:8];
        end
        else if (get_data) begin
            count<=count-1;
        end
    end
endcase
end
end
endmodule