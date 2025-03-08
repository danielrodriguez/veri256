module integ_tb;
reg clk, rst_n, start;
reg [255:0] b, a, m;
wire [255:0] c;
wire ready, busy, ready0;
modinv inst (clk, rst_n, start, b, a, m, c, ready, busy, ready0);
    initial begin
        #0 clk = 1;
        #0 rst_n = 0;
        #0 start = 0;
        #0 a = 256'hfed5b7e864ae24ed502e69af8acfe4c97190cbac30c2728c0d87afc60791219a;
        #0 b = 256'h1;
        #0 m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        #1 rst_n = 1;
        #2 start = 1;
        #2 start = 0;
        
        while(!ready)
            #1;
        $display("c = %h", c);
        #40 $finish;
    end
    always #1 clk = !clk;
endmodule