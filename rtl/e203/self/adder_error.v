//----------------------------------------------------------------------------
// Project Name  : Soc_lab1
// Author        : Lisp
// Last Modified : 2023/03/21 
// File Name     : adder.v
// Description   : 32 bit unsigned adder module
//                 Errors are designed in this module, please debug this module before E203 SoC
//
//----------------------------------------------------------------------------

module adder (
	input              clk,
	input              rst_n,
	input       [31:0] in1,
	input       [31:0] in2,
	input 			   enable,
	input			   clear,
	output      [31:0] out,
	output			   overflow
);

reg   [16:0]   lsum_d1, usum_d2;
reg   [16:0]   lsum_d1_nxt, usum_d2_nxt;
reg	 	       carry_d1;	
reg   [15:0]   lsum_d2, aup_d1, bup_d1;
reg   [32:0]   out_64;

assign lsum_d1_nxt = in1[15:0] + in2[15:0];
assign carry_d1    = lsum_d1[16];
assign usum_d2_nxt = carry_d1 + aup_d1 + bup_d1;
assign out_64 	   = {usum_d2, lsum_d2};
assign out         = out_64[31:0];
assign overflow	   = usum_d2[16] ^ usum_d2[15];


always @(posedge clk or posedge rst_n) begin
	if (!rst_n) begin
			lsum_d1 <= 'd0;
			lsum_d2 <= 'd0;
			aup_d1  <= 'd0;
			bup_d1  <= 'd0;
			usum_d2 <= 'd0;
	end
	else begin
		if (enable) begin
			if (clear) begin
				begin
					lsum_d1 <= 'd0;
					lsum_d2 <= 'd0;
					aup_d1  <= 'd0;
					bup_d1  <= 'd0;
					usum_d2 <= 'd0;
				end
			end
			else begin
				lsum_d1 <= lsum_d1_nxt;
				lsum_d2 <= lsum_d1[15:0];
				aup_d1  <= in1[31:16];
				bup_d1  <= in2[31:16];
				usum_d2 <= usum_d2_nxt;
			end
		end
	end
end



endmodule
