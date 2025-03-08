BOARD?=xc7s25

test: check build
	vvp keccak.vvp && \
	vvp ecc_point_add.vvp && \
	vvp ecc_point_double.vvp && \
	vvp ecc_point_mult.vvp && \
	vvp rv32i_arith.vvp && \
	vvp rv32i_point.vvp

check: top

load: pack
# TODO, add PNR and pack to the makefile
	openFPGALoader -b ${BOARD} guiso.fs 

top: 
	iverilog -g2005-sv ecc/func.v ecc/ecc.v  top.v uart.v ./keccak/*.v 
clean: 
	rm *.vvp a.out || true
build: clean
	iverilog  -o keccak.vvp -g2005-sv keccak/*  && \
	iverilog   -o ecc_point_add.vvp -g2005-sv ecc/func.v ecc/ecc.v ecc/point_add_test.v && \
	iverilog   -o ecc_point_double.vvp -g2005-sv ecc/func.v ecc/ecc.v ecc/point_double_test.v && \
	iverilog   -o modular_inverse_test.vvp -g2005-sv ecc/func.v ecc/ecc.v ecc/modular_inverse_test.v && \
	iverilog   -o ecc_point_mult.vvp -g2005-sv ecc/func.v ecc/ecc.v ecc/point_scalar_mult_test.v && \
	iverilog   -o rv32i_arith.vvp -g2005-sv riscv/rv32i.v riscv/rv32i_arith_tb.v && \
	iverilog   -o rv32i_point.vvp -g2005-sv riscv/rv32i.v riscv/rv32i_point_tb.v
	
synth: check 
	yosys -p "read_verilog -sv ecc/func.v ecc/ecc.v ./top.v ./uart.v ./keccak/*.v ; synth_xilinx  -top top"	
# yosys -p "read_verilog -sv ecc/func.v ecc/ecc.v ./top.v ./uart.v ./keccak/*.v ; synth_gowin  -top top -json gowin_qguiso.json"