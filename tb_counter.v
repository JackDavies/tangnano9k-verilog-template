`timescale 1ns / 1ps
`define DEBUG
`include "counter.v"

module tb_counter;
	reg clk;
	reg btn1;
	reg btn2;
    reg i = 0;


	top uut(
	  .clk(clk),
	  .btn1(btn1),
	  .btn2(btn2)
	);

	initial begin
		clk = 0;
		btn1 = 1;
		btn2 = 1;

        $dumpfile("./sim/tb_counter.vcd");
        $dumpvars(0, tb_counter);

		#10;

		repeat (100) begin
			clk = ~clk;
			#5;
		end

		#25;

		btn2 = 1;
		#5;
		btn2 = 0;

		repeat(50) begin
			repeat (10) begin
				btn1 = 1;
				clk = ~clk;
				#5;
			end
			repeat (10) begin
				btn1 = 0;
				clk = ~clk;
				#5;
			end
		end
		
		$finish;
	end
endmodule
