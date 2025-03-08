module modmul_tb;
reg clk, rst_n, start;
reg [255:0] b, a, m;
wire [255:0] p;
wire ready;
    
    modmul inst (clk, rst_n, start, a, b, m, p, ready);

    always #1 clk = !clk;
    
    initial begin
        #0 clk = 1;
        #0 rst_n = 0;
        #0 start = 0;
        // p = a * b mod m
        #0 a = 256'hfd15b0a9c566cba7317e8c0826356ca9fd88cc6d49d48c180bded20418f92715;
        #0 b = 256'h7124f3c9f53b546921ab91834a6c099a6556abda6c89306c6ff86f48683a5645;
        #0 m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        #1 rst_n = 1;
        #2 start = 1;
        #2 start = 0;
        
        while(!ready)
            #1;
        check(256'h3fa6d1e798fbb60e476965b2e5411d76f14c4761330282fe62e5bedf68a463e7);
        $display("✅all good!");
        $finish;
    end
     task check;
        input [256:0] wish;
        begin
          if (p !== wish)
            begin
              $display("❌ actual:%h  --  expected: %h", p, wish);  $finish;
            end
        end
    endtask
endmodule