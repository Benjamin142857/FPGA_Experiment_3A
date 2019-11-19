module main_clock(CLK, RST, LOAD, key_H, key_M, key_S, Hh, Hl, Mh, Ml, Sh, Sl, isFull);
	input CLK, RST, LOAD; 				// CLK时钟, RST复位, LOAD调点
	input key_H, key_M, key_S; 		// 按键调时，按键调分，按键调秒
	output [3:0] Hh, Hl;		   		// 时-十位个位
	output [3:0] Mh, Ml;		   		// 分-十位个位
	output [3:0] Sh, Sl;		   		// 秒-十位个位
	output isFull;			  	   			// 是否整点

	reg [4:0] H;		// 时-完整数据 (0~23, 5位)
	reg [5:0] M;		// 分-完整数据 (0~59, 6位)
	reg [5:0] S;		// 秒-完整数据 (0~59, 6位)
	reg isFull;
	reg [3:0] Hh, Hl, Mh, Ml, Sh, Sl;
	
	always@(posedge CLK) begin
		// 非调点置数状态
		if (!LOAD) begin
			// 2. 复位 00:00:00
			if (RST) begin
				H = 5'b00000;
				M = 6'b000000;
				S = 6'b000000;
			end
			
			// 3. 正常时钟
			else begin
				// 3.1 秒
				if(S < 6'b111011) S=S+1;
				else begin
					M = M + 1;
					S = 6'b000000;
				end
				
				// 3.2 分
				if(M == 6'b111100) begin
					H = H + 1;
					M = 6'b000000;
				end
					
				// 3.3 时
				if(H == 5'b11000) H = 5'b00000;
				
			end
		
		end
		
		
		// 输出
		Hh = H/10;
		Hl = H%10;
		Mh = M/10;
		Ml = M%10;
		Sh = S/10;
		Sl = S%10;
		
		// 整点报
		if (S==6'b000000 && M==6'b000000) isFull = 1;
		else isFull = 0;
		
	end
endmodule