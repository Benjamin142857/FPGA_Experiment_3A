module main_clock(CLK, RST, LOAD, Hh, Hl, Mh, Ml, Sh, Sl, isFull);
	input CLK, RST, LOAD; 		// CLK时钟, RST复位, LOAD调点
	output [3:0] Hh, Hl;		   // 时-十位个位
	output [3:0] Mh, Ml;		   // 分-十位个位
	output [3:0] Sh, Sl;		   // 秒-十位个位
	output isFull;			  	   // 是否整点

	reg [4:0] H;		// 时-完整数据 (0~23, 5位)
	reg [5:0] M;		// 分-完整数据 (0~59, 6位)
	reg [5:0] S;		// 秒-完整数据 (0~59, 6位)

	always@(posedge CLK, negedge RST) begin
		/*
		COUT = 1'b0;
	
		if (!RST) Q1 <= 0;
		else if (EN) begin
			if (!LOAD) Q1 <= DATA;
			else if (Q1>0) Q1 <= Q1-1;
			else begin 
				Q1 <= 4'b1001;
				COUT = 1'b1;
			end
		end
		*/
	end
endmodule