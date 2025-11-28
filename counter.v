module top
(
    input clk,
	input btn1,
	input btn2,
    output [5:0] led
);

`ifdef DEBUG
localparam WAIT_TIME = 5;
`else
localparam WAIT_TIME = 13500000;
`endif

reg [5:0] ledCounter = 0;
reg [23:0] clockCounter = 0;
reg run = 1;


always @(posedge clk) begin
	if (run == 1) begin
		clockCounter <= clockCounter + 1;
		if (clockCounter == WAIT_TIME) begin
		    clockCounter <= 0;
		    ledCounter <= ledCounter + 1;
		end
	end

	if (btn2 == 0) begin
		ledCounter <= 0;
	end
end

always@(negedge btn1) begin
	run <= ~run;
end

//always @(posedge btn2) begin
//	clockCounter <= 0;
//end

assign led = ~ledCounter;
endmodule
