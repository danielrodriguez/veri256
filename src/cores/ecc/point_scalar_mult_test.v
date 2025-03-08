
module point_scalar_mult_test;
reg clk, rst_n, start;
reg [255:0] px, py, pz, m;
reg [255:0] d;
wire [255:0] rx, ry, rz;
wire ready;

    point_scalar_mult inst (clk, rst_n, start, px, py, pz, m, d, rx, ry, rz, ready);
    
    always #1 clk = ~ clk;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
    end

    initial begin
    // $dumpfile("test.vcd");
    // $dumpvars(0,point_scalar_mult_test);
        #1;
        rst_n = 0;
        #5;
        rst_n = 1;
        m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        px = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
        py = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
        pz = 256'd1;
        d = 256'ha;
        start = 1;
        #1
        while(ready == 0) 
          #1;
        check(256'h4f72a7d24f52d72721eb6bb94e5b0686a19cbb1e88c0e0d03622bb554af48f0d,
        256'h5295bc17c2c5e707c9fc88110a0ee54615f5871bcf4697e3024741b481b84821,
        256'hcdc375fe5548240778843205a801f2d0a63bc5fdbaf318dab50ef18a7e5065db);
        
        $display("✅all good!");
        $finish;
    end

      task check;
        input [256:0] wishx, wishy, wishz;
        begin
          if (rx !== wishx)
            begin
              $display("❌ x actual: %0h", rx); 
              $display("❌ x expect: %0h", wishx); 
            end
          if (ry !== wishy)
            begin
              $display("❌ y actual: %0h ", ry);
              $display("❌ y expect: %0h", wishy); 
            end
          if (rz !== wishz)
            begin
              $display("❌ z actual: %0h", rz); 
              $display("❌ z expect: %0h", wishz); 
            end

            if (rx !== wishx | ry !== wishy | rz !== wishz)
              $finish;
        end
    endtask
endmodule
          
       
         
