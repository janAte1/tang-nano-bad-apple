module decoder(
input clk,
input get_data,
input reg[15:0] buf,
output reg out = 1,
output ready);

localparam STATE_AWAITING = 2'd0;
localparam STATE_BLACK = 2'd1;
localparam STATE_WHITE = 2'd2;
localparam STATE_DONE = 2'd3
reg state = STATE_AWAITING;
[7:0] reg count = 0;
always @(posedge clk) begin
    if state_done
    if (get_data) begin
        if (count==0) begin
            count<=
        end else begin
            count<=count-1;
        end
    end
end

endmodule