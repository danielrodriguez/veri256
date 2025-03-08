module rv32i_point_tb;
    reg clk = 0;
    reg rst_n = 0;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    reg [31:0] mem_rdata;
    wire mem_we;
    
    reg [31:0] memory [1023:0];
    always #5 clk = ~clk;
    
    rv32i dut (
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_rdata(mem_rdata),
        .mem_we(mem_we)
    );
    
    always @(*) begin
        mem_rdata = memory[mem_addr[11:2]];
        // $display("mem load [%d] = %h", mem_addr[11:2], memory[mem_addr[11:2]]);
    end
    
    always @(posedge clk) begin
        if (mem_we) begin
            memory[mem_addr[11:2]] <= mem_wdata;
        end
    end
    
    initial begin
        for (integer i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h0;
        end
        
        memory[8]  = 32'h11111111; 
        memory[9]  = 32'h22222222;
        memory[10] = 32'h33333333;
        memory[11] = 32'h44444444;
        memory[12] = 32'h55555555;
        memory[13] = 32'h66666666;
        memory[14] = 32'h77777777;
        memory[15] = 32'h88888888; 
        
        memory[0] = 32'h02000093;  // addi x1, x0, 32 (32=memory[8])
        memory[1] = 32'h0010B0B7;  // loadp x1, x1 
        
        rst_n = 0;
        #20 rst_n = 1;
        
        #1500;
        
        if (dut.point_registers[1] == 256'h8888888877777777666666665555555544444444333333332222222211111111)
            $display("✅ POINT instruction test passed!");
        else
            $display("❌ POINT instruction test failed!");
        
        $finish;
    end
endmodule
