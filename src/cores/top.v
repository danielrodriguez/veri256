`default_nettype none

module top
#( 
    parameter WAIT_TIME = 12000000
)
(
    input clk,
    output uart_tx
);

reg start, rst_n;
reg keccak_rst, inv_rst_n, mul_rst_n;
reg [255:0] px, py, pz, m;
reg [255:0] rx, ry;
reg [255:0] d;
wire [255:0] qx, qy, qz, qz2, qz3, zi;
wire [255:0] keccakout;
wire ready, readyqz2, readyqz3, readyrx, readyry, keccakready, readyzi;
reg cen_n;

wire [3:0] uartBusy;
reg [63:0] opc = 0;
reg [127:0] payload;
reg [63:0] clockCounter = 0;
reg [1:0]  state = 0;
wire [543:0]  keccak_in;

    point_scalar_mult inst (clk, rst_n, start, px, py, pz, m, d, qx, qy, qz, ready);
    uart uu (clk, payload, cen_n, uart_tx, uartBusy);
    
    modinv zinv (clk, mul_rst_n, ready, 256'b1, qz, m, zi, readyzi);
    modmul z2mult (clk, mul_rst_n, readyzi, zi, zi, m, qz2, readyqz2); // qz2=1/qz^2
    modmul z3mult (clk, mul_rst_n, readyqz2, zi, qz2, m, qz3, readyqz3); // qz3=1/qz^3

    modmul rxmult (clk, inv_rst_n, readyqz2, qx, qz2, m, rx, readyrx); // qz*qz2
    modmul rymult (clk, inv_rst_n, readyqz3, qy, qz3, m, ry, readyry);

    // modmul z2mult (clk, mul_rst_n, ready, qz, qz, m, qz2, readyqz2);
    // modmul z3mult (clk, mul_rst_n, readyqz2, qz2, qz, m, qz3, readyqz3);

    // modinv z2inv (clk, inv_rst_n, readyqz2, qz2, qx, m, rx, readyrx);
    // modinv z3inv (clk, inv_rst_n, readyqz3, qz3, qy, m, ry, readyry);


    assign keccak_in = {rx, ry, 32'b0};

    keccak uut (
        .clk(clk),
        .reset(keccak_rst),
        .in(keccak_in),
        .in_ready(readyry & readyrx),
        .is_last(readyry & readyrx),
        .byte_num(8'd64),
        .out(keccakout),
        .out_ready(keccakready)
    );


    initial begin
          m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
          px = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
          py = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
          pz = 256'h1;
          d = 256'hcafebabe000;
          rst_n = 0;
          inv_rst_n = 0;
          mul_rst_n = 0;

          keccak_rst = 1;
          start = 1;
          opc = 0;
          payload = { 16'hffff, 112'h0};
          state = 0;
    end

     always @(posedge clk) begin
        clockCounter = clockCounter + 1;
    // $display("state = %0d", state);
case(state) 
    0: begin
        if ((keccak_rst == 1 | inv_rst_n == 0 | mul_rst_n == 0 | rst_n == 0) & clockCounter > 10) begin
                keccak_rst = 0;
                inv_rst_n = 1;
                mul_rst_n = 1;
               rst_n = 1;
            start = 1;
            state = 1;
        end
    end
    1: begin // checks

            if (keccakready) begin
                    
                    rst_n = 0;
                    inv_rst_n = 0;
                    mul_rst_n = 0;
                    keccak_rst = 1;
                    start = 0;

                    opc = opc + 1;
                    d = d + 1;
                    state = 2;
            end 
    end
    2: begin //reset
            if (keccakready) begin
                keccak_rst = 1;
            end
            if (readyrx | readyry) begin
                inv_rst_n = 0;
            end
            if (readyzi | readyqz2 | readyqz3) begin
                mul_rst_n = 0;
            end
            if (ready) begin
               rst_n = 0;
            end
        if (!keccakready && !ready) begin
            
            // $display("flop! state = 0");
            rst_n = 1;
            mul_rst_n = 1;
            inv_rst_n = 1;
            keccak_rst = 0;
            start =1 ;
            state= 1;
        end
    end
endcase
        if (uartBusy == 0 && clockCounter > WAIT_TIME-20000) begin
            cen_n = 0;
        end else begin
            cen_n = 1;
        end

        if (clockCounter == WAIT_TIME) begin
            clockCounter = 0;
            opc = 0;
        end 
        
        
    end

endmodule
