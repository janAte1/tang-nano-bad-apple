module flashReader
#(
  parameter STARTING_ADDRESS = 24'h10_00_00
)
(
    input clk,
    output flashClk,
    input flashMiso, 
    output reg flashMosi = 0,
    output reg flashCs = 1,
    input next, // synchronous signal to load next 16 bits
    input rst,  // asynchronous signal to return to starting address,
    output reg [15:0] out = 0,
    output reg dataReady = 0
);
localparam STARTUP_WAIT = 32'd1000000;
localparam INIT_COMMAND = 32'h03<<24|STARTING_ADDRESS;

localparam STATE_INIT_POWER = 8'd0;
localparam STATE_SEND = 8'd2;
localparam STATE_READ_DATA = 8'd3;
localparam STATE_DONE = 8'd4;

reg enableClock = 0;
assign flashClk = ~clk & enableClock;

reg [31:0] initCommand = 32'h0;
reg [5:0]  bitCounter = 0;
reg [32:0] counter = 0;
reg [2:0] state = STATE_INIT_POWER;

reg misoSampled = 0;
always @(negedge clk) begin
    misoSampled <= flashMiso;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state<=STATE_INIT_POWER;
        flashCs <= 1;
        enableClock <= 0;
        dataReady <= 0;
    end else begin
        case (state)
            STATE_INIT_POWER: begin
            if (counter == STARTUP_WAIT) begin
                state <= STATE_SEND;
                counter <= 32'b0;
                initCommand<=INIT_COMMAND;
                bitCounter <= 0;
                dataReady <= 0;
                out <= 0;
            end else counter <= counter + 1;
            end
            STATE_SEND: begin
                flashCs <= 0;
                enableClock <= 1;

                flashMosi <= initCommand[31];
                initCommand <= {initCommand[30:0],1'b0};
                // waiting extra cycle for MISO line to be sampled at clk negedge
                if (bitCounter == 32) begin
                    state <= STATE_READ_DATA;
                    bitCounter<=0;
                end else bitCounter<=bitCounter+1;
            end
            STATE_READ_DATA: begin
                out <= {out[14:0], misoSampled};
                if (bitCounter == 15) begin
                    bitCounter <= 0;
                    dataReady <= 1;
                    enableClock <= 0;
                    state <= STATE_DONE;
                end else bitCounter<=bitCounter+1;
            end
            STATE_DONE: begin
                if (next) begin
                    state <= STATE_READ_DATA;
                    enableClock <= 1;
                    dataReady <= 0;
                end
            end
        endcase
    end
end
endmodule