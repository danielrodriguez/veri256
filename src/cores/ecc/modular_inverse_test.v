module modinv_tb;
reg clk, rst_n, start;
reg [255:0] b, a, m;
wire [255:0] c;
wire ready;
    
    modinv inst (clk, rst_n, start, b, a, m, c, ready);

    always #1 clk = !clk;
    
    initial begin
        #0 clk = 1;
        #0 rst_n = 0;
        #0 start = 0;
        // c = b * a^{-1} mod m
        // x_aff = modinv(modmul (z_j,z_j), x_j)
        // y_aff = modinv(modmul (z_j,z_j), y_j)
        #0 a = 256'h8a85638b56a4e194b87704f6f4fdf8831bcc4d8762d627e9bc40b0d427fc13c9;
        #0 b = 256'hfed5b7e864ae24ed502e69af8acfe4c97190cbac30c2728c0d87afc60791219a;
        #0 m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        #1 rst_n = 1;
        #2 start = 1;
        #2 start = 0;
        
        while(!ready)
            #1;
        check(256'hacd11bb4ed4278829d0c01d61e87bcca10c19e3cabcb8545370e8bb49b57f13a);
        $display("✅all good!");
        $finish;
    end
    
    task check;
        input [256:0] wish;
        begin
          if (c !== wish)
            begin
              $display("❌ actual:%h  --  expected: %h", c, wish);  $finish;
            end
        end
    endtask
endmodule