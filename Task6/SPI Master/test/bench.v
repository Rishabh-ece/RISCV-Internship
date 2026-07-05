`timescale 1ns / 1ps

module SB_HFOSC(
	input CLKHFPU,
	input CLKHFEN,
	output CLKHF
	);
	parameter CLKHF_DIV = "0b00";
	reg clk_gen = 0;
	always #20 clk_gen = ~clk_gen;
	assign CLKHF = clk_gen;
endmodule

module SB_PLL40_CORE(
	input REFERENCECLK,
	input RESETB,
	input BYPASS,
	output PLLOUTCORE
	);
	parameter FEEDBACK_PATH = "SIMPLE";
	parameter PLLOUT_SELECT = "GENCLK";
	parameter DIVR = 4'b0000;
	parameter DIVF = 7'b0000000;
	parameter DIVQ = 3'b000;
	parameter FILTER_RANGE = 3'b001;
	
	assign PLLOUTCORE = REFERENCECLK;
endmodule
	

module bench;
	reg RESET = 1;
	wire [4:0] LEDS;
	wire TXD;
	reg RXD =1;
	
	SOC uut(
	.RESET(RESET),
	.LEDS(LEDS),
	.RXD(RXD),
	.TXD(TXD)
	);
	assign uut.spi_miso = uut.spi_mosi;
	
	initial begin
	$dumpfile("spi_sim.vcd");
	$dumpvars(0, bench);
	RESET = 1;
	#100;
	RESET = 0;
	#200000000;
	$finish;
	end
endmodule
