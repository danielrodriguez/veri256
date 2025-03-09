module point_scalar_mult_c_test;
    reg clk, rst_n, start;
    reg [255:0] px, py, m, d;
    wire [255:0] rx, ry;
    wire ready;

    point_scalar_mult_c inst (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start), 
        .px(px), 
        .py(py), 
        .m(m), 
        .d(d), 
        .rx(rx), 
        .ry(ry), 
        .ready(ready)
    );

    always #1 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        px = 256'h0;
        py = 256'h0;
        m = 256'h0;
        d = 256'h0;
    end

    initial begin
   
        #1;
        rst_n = 0;
        #10; 
        rst_n = 1;
        #2;  
        
        m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        px = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
        py = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
        d = 256'hcafebabe000;
        
        #2; 
        start = 1;

        while (ready == 0)
           #100;
        
        #10; 
        check(256'he162adff37e510a34530f5dac8d39139dfe625cbe5d9f1fcf1d8b8b41dadf696,
              256'h93c56a48c0c4ba17234204abcc4defafbdf7cb5dc2232293ca75694b8ccca669);
        
        $display("✅ all good!");
        $finish;
    end

    task check;
        input [255:0] wishx, wishy;
        begin
            if (rx !== wishx) begin
                $display("❌ x actual: %0h", rx); 
                $display("❌ x expect: %0h", wishx); 
            end
            if (ry !== wishy) begin
                $display("❌ y actual: %0h", ry);
                $display("❌ y expect: %0h", wishy); 
            end

            if (rx !== wishx || ry !== wishy)
                $finish;
        end
    endtask
endmodule
