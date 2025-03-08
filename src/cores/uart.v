`default_nettype none

module uart
#(
    parameter DELAY_FRAMES = 234 // 27,000,000 (27Mhz) / 115200 Baud rate
)
(
    input clk,
    input [127:0] payload,
    input ready,
    output uart_tx,
    output [3:0] busy
);

localparam HALF_DELAY_WAIT = (DELAY_FRAMES / 2);

reg [3:0] txState = 0;
reg [24:0] txCounter = 0;
reg [7:0] dataOut = 0;
reg txPinRegister = 1;
reg [2:0] txBitNumber = 0;
reg [3:0] txByteCounter = 0;

assign uart_tx = txPinRegister;

localparam MEMORY_LENGTH = 16;

localparam TX_STATE_IDLE = 0;
localparam TX_STATE_START_BIT = 1;
localparam TX_STATE_WRITE = 2;
localparam TX_STATE_STOP_BIT = 3;
localparam TX_STATE_DEBOUNCE = 4;
assign busy = txState;
always @(posedge clk) begin
    // $display("state %d", txState);
    case (txState)
        TX_STATE_IDLE: begin
            if (ready == 0) begin
                // $strobe("starting to write");
                txState <= TX_STATE_START_BIT;
                txCounter <= 0;
                txByteCounter <= MEMORY_LENGTH - 1;
            end
            else begin
                txPinRegister <= 1;
            end
        end 
        TX_STATE_START_BIT: begin
            txPinRegister <= 0;
            if ((txCounter + 1) == DELAY_FRAMES) begin
                txState <= TX_STATE_WRITE;
                dataOut <= payload[txByteCounter*8+:8];
                // $strobe("moving to write %d,  %0h", txByteCounter, dataOut);
                txBitNumber <= 0;
                txCounter <= 0;
            end else 
                txCounter <= txCounter + 1;
        end
        TX_STATE_WRITE: begin
            txPinRegister <= dataOut[txBitNumber];
            if ((txCounter + 1) == DELAY_FRAMES) begin
                if (txBitNumber == 3'b111) begin
                    txState <= TX_STATE_STOP_BIT;
                end else begin
                    txState <= TX_STATE_WRITE;
                    txBitNumber <= txBitNumber + 1;
                end
                txCounter <= 0;
            end else 
                txCounter <= txCounter + 1;
        end
        TX_STATE_STOP_BIT: begin
            txPinRegister <= 1;
            if ((txCounter + 1) == DELAY_FRAMES) begin
                if (txByteCounter == 0) begin
                    txState <= TX_STATE_DEBOUNCE;
                end else begin
                    txByteCounter <= txByteCounter - 1;
                    txState <= TX_STATE_START_BIT;
                end
                txCounter <= 0;
            end else 
                txCounter <= txCounter + 1;
        end
        TX_STATE_DEBOUNCE: begin
            if (txCounter == 23'b111111111111111111) begin
                // $display("debounced, ready = %d", ready);
                // if (ready == 1) 
                    txState <= TX_STATE_IDLE;
            end else
                txCounter <= txCounter + 1;
        end
    endcase      
end
endmodule