module rv32i_arith_tb;
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
    end
    
    always @(posedge clk) begin
        if (mem_we) memory[mem_addr[11:2]] <= mem_wdata;
    end
    
    initial begin
        memory[0] = 32'h00400093;  // addi x1, x0, 4
        memory[1] = 32'h00200113;  // addi x2, x0, 2
        memory[2] = 32'h002081b3;  // add  x3, x1, x2
        memory[3] = 32'h40208233;  // sub  x4, x1, x2
        
        rst_n = 0;
        #20 rst_n = 1;
        #400;  
        
       
                 
        if (dut.registers[3] == 6 && dut.registers[4] == 2)
            $display("✅ add/sub ok");
        else
            $display("❌!add/sub");
        
        $finish;
    end
endmodule
