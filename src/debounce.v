// based on https://forum.digikey.com/t/debounce-logic-circuit-vhdl/12573
module debouncer
#(parameter TRESHOLD=1000)
(input clk, btn,
output reg out);

reg ff1;
reg ff2;
localparam COUNTER_WIDTH=$clog2(TRESHOLD);
reg [COUNTER_WIDTH+1:0] ctr = 0;
assign btn_change = ff1^ff2;
reg debounced_button;

always @(posedge clk) begin
    out<=0;
    ff1<=btn;
    ff2<=ff1;
    if (btn_change) ctr<=0;
    else if (ctr<TRESHOLD) ctr<=ctr+1'b1;
    else begin
        debounced_button<=ff2;
        // on rising edge give out a pulse
        if (debounced_button == 0 && ff2 == 1) out<=1;
    end
end

endmodule