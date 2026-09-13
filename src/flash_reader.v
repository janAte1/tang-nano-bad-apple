// arena.ai was used to implement proper flash reset logic
module flash_reader
#(
  parameter STARTING_ADDRESS = 24'h10_00_00
)
(
    input clk,
    output flash_clk,
    input flash_miso, 
    output reg flash_mosi = 0,
    output reg flash_cs = 1,
    input next,
    input rst,
    output reg [15:0] out = 0,
    output reg dataReady = 0
);
localparam STARTUP_WAIT = 32'd1000000;
localparam INIT_COMMAND = {8'h03, STARTING_ADDRESS};

localparam STATE_INIT_POWER    = 4'd0;
localparam STATE_BREAK_DUAL    = 4'd1;  // Send 0xFF bytes to break continuous read
localparam STATE_BREAK_GAP     = 4'd2;  // CS high gap after break
localparam STATE_RESET_ENABLE  = 4'd3;  // Send 0x66
localparam STATE_RESET_GAP     = 4'd4;  // CS high gap
localparam STATE_RESET_DEVICE  = 4'd5;  // Send 0x99
localparam STATE_RESET_WAIT    = 4'd6;  // Wait for flash reset
localparam STATE_SEND          = 4'd7;  // Send 0x03 + address
localparam STATE_READ_DATA     = 4'd8;
localparam STATE_DONE          = 4'd9;

reg enableClock = 0;
assign flash_clk = ~clk & enableClock;

reg [31:0] initCommand = 32'h0;
reg [5:0]  bitCounter = 0;
reg [32:0] counter = 0;
reg [3:0]  state = STATE_INIT_POWER;
reg [7:0]  shiftOut = 0;
reg [3:0]  byteCount = 0;

reg misoSampled = 0;
always @(negedge clk) begin
    misoSampled <= flash_miso;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state       <= STATE_INIT_POWER;
        flash_cs     <= 1;
        enableClock <= 0;
        flash_mosi   <= 0;
        dataReady   <= 0;
        counter     <= 0;
        bitCounter  <= 0;
        byteCount   <= 0;
    end else begin
        case (state)

            // ---- Wait for power stabilization ----
            STATE_INIT_POWER: begin
                flash_cs <= 1;
                if (counter == STARTUP_WAIT) begin
                    state      <= STATE_BREAK_DUAL;
                    counter    <= 0;
                    bitCounter <= 0;
                    byteCount  <= 0;
                    shiftOut   <= 8'hFF;
                    flash_cs    <= 0;
                    enableClock <= 1;
                end else begin
                    counter <= counter + 1'b1;
                end
            end

            // ---- Send multiple 0xFF bytes to break out of ----
            // ---- dual/quad continuous read mode            ----
            // The flash in continuous-read mode interprets incoming
            // bits as "mode bits" or continuation addresses.
            // Sending all-1s on MOSI guarantees the mode bits
            // are set to "exit continuous read" (0xFF = no continue)
            // regardless of where the flash thinks it is in the
            // command sequence. We send 8 bytes (64 clocks) to
            // cover all possible stuck states.
            STATE_BREAK_DUAL: begin
                flash_mosi <= shiftOut[7];
                shiftOut  <= {shiftOut[6:0], 1'b1};
                if (bitCounter == 7) begin
                    bitCounter <= 0;
                    shiftOut   <= 8'hFF;
                    if (byteCount == 7) begin
                        // Done sending 8 bytes of 0xFF
                        flash_cs     <= 1;
                        enableClock <= 0;
                        state       <= STATE_BREAK_GAP;
                        counter     <= 0;
                    end else begin
                        byteCount <= byteCount + 1'b1;
                    end
                end else begin
                    bitCounter <= bitCounter + 1'b1;
                end
            end

            // ---- CS high gap after break sequence ----
            STATE_BREAK_GAP: begin
                flash_cs <= 1;
                if (counter == 50) begin
                    // Now pull CS low again briefly and back high
                    // to ensure a clean CS edge for the flash
                    state      <= STATE_RESET_ENABLE;
                    counter    <= 0;
                    shiftOut   <= 8'h66;
                    bitCounter <= 0;
                    flash_cs    <= 0;
                    enableClock <= 1;
                end else begin
                    counter <= counter + 1'b1;
                end
            end

            // ---- Send 0x66 Reset Enable ----
            STATE_RESET_ENABLE: begin
                flash_mosi <= shiftOut[7];
                shiftOut  <= {shiftOut[6:0], 1'b0};
                if (bitCounter == 7) begin
                    flash_cs     <= 1;
                    enableClock <= 0;
                    state       <= STATE_RESET_GAP;
                    counter     <= 0;
                    bitCounter  <= 0;
                end else begin
                    bitCounter <= bitCounter + 6'b1;
                end
            end

            // ---- CS high gap ----
            STATE_RESET_GAP: begin
                if (counter == 50) begin
                    shiftOut    <= 8'h99;
                    bitCounter  <= 0;
                    flash_cs     <= 0;
                    enableClock <= 1;
                    state       <= STATE_RESET_DEVICE;
                end else begin
                    counter <= counter + 1'b1;
                end
            end

            // ---- Send 0x99 Reset Device ----
            STATE_RESET_DEVICE: begin
                flash_mosi <= shiftOut[7];
                shiftOut  <= {shiftOut[6:0], 1'b0};
                if (bitCounter == 7) begin
                    flash_cs     <= 1;
                    enableClock <= 0;
                    state       <= STATE_RESET_WAIT;
                    counter     <= 0;
                    bitCounter  <= 0;
                end else begin
                    bitCounter <= bitCounter + 1'b1;
                end
            end

            // ---- Wait for flash internal reset (~30µs = ~810 cycles @ 27MHz) ----
            STATE_RESET_WAIT: begin
                flash_cs <= 1;
                if (counter == 2000) begin
                    state       <= STATE_SEND;
                    counter     <= 0;
                    initCommand <= INIT_COMMAND;
                    bitCounter  <= 0;
                end else begin
                    counter <= counter + 1'b1;
                end
            end

            // ---- Send 0x03 + 24-bit address ----
            STATE_SEND: begin
                flash_cs     <= 0;
                enableClock <= 1;
                flash_mosi   <= initCommand[31];
                initCommand <= {initCommand[30:0], 1'b0};
                if (bitCounter == 32) begin
                    state      <= STATE_READ_DATA;
                    bitCounter <= 0;
                end else begin
                    bitCounter <= bitCounter + 1'b1;
                end
            end

            // ---- Read 16 bits ----
            STATE_READ_DATA: begin
                out <= {out[14:0], misoSampled};
                if (bitCounter == 15) begin
                    bitCounter  <= 0;
                    dataReady   <= 1;
                    enableClock <= 0;
                    state       <= STATE_DONE;
                end else begin
                    bitCounter <= bitCounter + 1'b1;
                end
            end

            // ---- Wait for next request ----
            STATE_DONE: begin
                if (next) begin
                    state       <= STATE_READ_DATA;
                    enableClock <= 1;
                    dataReady   <= 0;
                end
            end
        endcase
    end
end
endmodule