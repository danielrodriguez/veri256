/*
 * R-type (opcode 0110011):
 * - ADD  rd, rs1, rs2    (funct3=000, funct7=0000000)
 * - SUB  rd, rs1, rs2    (funct3=000, funct7=0100000)
 * 
 * I-type (opcode 0010011):
 * - ADDI rd, rs1, imm    (funct3=000)
 * 
 * Load (opcode 0000011):
 * - LW   rd, offset(rs1) (funct3=010)
 * 
 * Store (opcode 0100011):
 * - SW   rs2, offset(rs1) (funct3=010)
 * 
 * Custom Extensions:
 * - LOADP rd, rs1  (opcode 0001011) -- Loads 256-bit value starting from memory address in rs1 into 256-bit register rd
 * - MULP  rd, rs1  (opcode ?) -- ???
 */

module rv32i (
    input wire clk,
    input wire rst_n,
    // Memory interface
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    input wire [31:0] mem_rdata,
    output reg mem_we
);

    // Registers
    reg [31:0] registers [31:0];
    reg [31:0] pc;

    // 256-bit registers for LOADP operations (8 registers)
    reg [255:0] point_registers [7:0];
    
    // Instruction decode
    wire [6:0] opcode = mem_rdata[6:0];
    wire [4:0] rd = mem_rdata[11:7];
    wire [4:0] rs1 = mem_rdata[19:15];
    wire [4:0] rs2 = mem_rdata[24:20];
    wire [2:0] funct3 = mem_rdata[14:12];
    wire [6:0] funct7 = mem_rdata[31:25];
    
    // Immediate decode
    wire [31:0] imm_i = {{20{mem_rdata[31]}}, mem_rdata[31:20]};
    wire [31:0] imm_s = {{20{mem_rdata[31]}}, mem_rdata[31:25], mem_rdata[11:7]};
    
    reg [2:0] state;  // Changed to 3 bits for more states
    reg [2:0] point_counter;  // Counter for loading 256-bit values
    localparam FETCH = 3'b000;
    localparam EXECUTE = 3'b001;
    localparam POINT_LOAD = 3'b010;
    localparam POINT_READ = 3'b011;  // Added read state
    
    reg [255:0] point_temp;
    reg [31:0] point_base_addr;
    reg [2:0] point_rd;

    initial begin
        pc = 32'h0;
        state = FETCH;
        registers[0] = 32'h0;
        point_counter = 0;
        point_temp = 256'h0; 
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0;
            state <= FETCH;
            registers[0] <= 32'h0;
            point_counter <= 0;
            point_temp <= 256'h0;  
            mem_we <= 0;
        end else begin
            case (state)
                FETCH: begin
                    // $display("fetching pc %h",  pc );
                    mem_addr <= pc;
                    mem_we <= 0;
                    state <= EXECUTE;
                end
                
                EXECUTE: begin
                    // $display("executing opcode %b, funct3 = %b ",  opcode, funct3);
                    // Reset mem_we at start of execute
                    mem_we <= 0;
                    
                    case (opcode)
                        7'b0110011: begin // R-type
                            case (funct3)
                                3'b000: begin // ADD/SUB
                                    if (funct7 == 7'b0000000)
                                        registers[rd] <= (rd != 0) ? registers[rs1] + registers[rs2] : 0;
                                    else if (funct7 == 7'b0100000)
                                        registers[rd] <= (rd != 0) ? registers[rs1] - registers[rs2] : 0;
                                end
                            endcase
                            pc <= pc + 4;
                            state <= FETCH;
                        end
                        
                        7'b0010011: begin // I-type
                            case (funct3)
                                3'b000: begin
                                    // $display("addi registers[%d] = %d + %d ", rd, registers[rs1], imm_i);
                                    registers[rd] <= (rd != 0) ? registers[rs1] + imm_i : 0; // ADDI
                                end
                            endcase
                            pc <= pc + 4;
                            state <= FETCH;
                        end
                        
                        7'b0000011: begin // Load
                            mem_addr <= registers[rs1] + imm_i;
                            registers[rd] <= (rd != 0) ? mem_rdata : 0;
                            pc <= pc + 4;
                            state <= FETCH;
                        end
                        
                        7'b0100011: begin // Store
                            mem_addr <= registers[rs1] + imm_s;
                            mem_wdata <= registers[rs2];
                            mem_we <= 1;
                            pc <= pc + 4;
                            state <= FETCH;
                        end

                        7'b0110111: begin // LOADP instruction
                            // $display("loadp point_base_addr=registers[%d]=%b", rs1, registers[rs1]);
                            point_base_addr <= registers[rs1];
                            point_rd <= rd[2:0];
                            point_counter <= 0;
                            state <= POINT_LOAD;
                        end
                        
                        default: begin
                            pc <= pc + 4;
                            state <= FETCH;
                        end
                    endcase
                end
                
                POINT_LOAD: begin
                    mem_we <= 0;
                    case (point_counter)
                        0: begin
                            mem_addr <= point_base_addr;
                            state <= POINT_READ;
                        end
                        1: begin
                            mem_addr <= point_base_addr + 4;
                            state <= POINT_READ;
                        end
                        2: begin
                            mem_addr <= point_base_addr + 8;
                            state <= POINT_READ;
                        end
                        3: begin
                            mem_addr <= point_base_addr + 12;
                            state <= POINT_READ;
                        end
                        4: begin
                            mem_addr <= point_base_addr + 16;
                            state <= POINT_READ;
                        end
                        5: begin
                            mem_addr <= point_base_addr + 20;
                            state <= POINT_READ;
                        end
                        6: begin
                            mem_addr <= point_base_addr + 24;
                            state <= POINT_READ;
                        end
                        7: begin
                            mem_addr <= point_base_addr + 28;
                            state <= POINT_READ;
                        end
                    endcase
                end
                
                POINT_READ: begin
                    // Read the data and store in appropriate part of point_temp
                    case (point_counter)
                        0: begin 
                            point_temp[31:0] <= mem_rdata;
                        end
                        1: begin
                            point_temp[63:32] <= mem_rdata;
                        end
                        2: begin
                            point_temp[95:64] <= mem_rdata;
                        end
                        3: begin
                            point_temp[127:96] <= mem_rdata;
                        end
                        4: begin
                            point_temp[159:128] <= mem_rdata;
                        end
                        5: begin
                            point_temp[191:160] <= mem_rdata;
                        end
                        6: begin
                            point_temp[223:192] <= mem_rdata;
                        end
                        7: begin
                            point_temp[255:224] <= mem_rdata;
                        end
                    endcase
                    
                    if (point_counter < 7) begin
                        // $display("PC++ LOAD");
                        point_counter <= point_counter + 1;
                        state <= POINT_LOAD;
                    end else begin
                        point_registers[point_rd] <= {mem_rdata, point_temp[223:0]};
                        pc <= pc + 4;
                        state <= FETCH;
                    end
                end
            endcase
        end
    end

endmodule
