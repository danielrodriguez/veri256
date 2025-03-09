module integ_tb;
reg clk, rst_n, start;
reg [255:0] b, a, m;
wire [255:0] c;
wire ready;
modinv inst (clk, rst_n, start, b, a, m, c, ready);
    initial begin
        #0 clk = 1;
        #0 rst_n = 0;
        #0 start = 0;
        #0 a = 256'hfd17fead63b0f73b1f25378af4f4ccf41a26e81bfae64b63492bf47d406c14ad;
        #0 b = 256'h1;
        #0 m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        #1 rst_n = 1;
        #2 start = 1;
        
        while(!ready)
            #1;
        $display("c = %h", c);
        #40 $finish;
    end
    always #1 clk = !clk;
endmodule