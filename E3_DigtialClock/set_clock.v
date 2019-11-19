// 1. 调点置数功能
		if (LOAD) begin
			always@(posedge key_H, posedge key_M, posedge key_S) begin
				// 1.1 调时
				if(key_H) begin
					if(H==5'b10111) H=5'b00000;
					else H=H+1;
				end
				
				// 1.2 调分
				if(key_M) begin
					if(M==6'b111011) M=6'b000000;
					else M=M+1;
				end
				
				// 1.3 调秒
				if(key_S) begin
					if(S==6'b111011) S=6'b000000;
					else S=S+1;
				end
				
			end
		end