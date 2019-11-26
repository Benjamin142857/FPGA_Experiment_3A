% 
% DSP Builder (Version 2.1.2)
% Quartus II development tool and MATLAB/Simulink Interface
% $Revision: #1 $ 
% 
% Copyright © 2001-2003 Altera Corporation. All rights reserved.
% 
% The DSP Builder software, including, without limitation, the clock-cycle limited 
% versions of the MegaCore© Logic Functions included therein, may only be used to 
% develop designs for programmable logic devices manufactured by Altera Corporation 
% and sold by Altera Corporation and its authorized distributors. IN NO EVENT MAY 
% SUCH SOFTWARE AND FUNCTIONS BE USED TO PROGRAM ANY PROGRAMMABLE LOGIC DEVICES, FIELD
% PROGRAMMABLE GATE ARRAYS, ASICS, STANDARD PRODUCTS, OR ANY OTHER SEMICONDUCTOR 
% DEVICE MANUFACTURED BY ANY COMPANY OR ENTITY OTHER THAN ALTERA.  For the complete 
% terms and conditions applicable to your use of the software and functions, please 
% refer to the Altera Program License directory
% 
% $Id: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/DesignExamples/Demos/Filters/CicFilter/CicPLL/getb.m#1 $
%

function res = getb(i, R, N, CicType)


if(nargin==4)
	if (CicType ==0) % Interpolator
	 
		if (i>N)
		    G = (2^(2*N-i)*(R^(i-N)))/R;
		else
		    G = 2^i;
		end
		ibit = ceil(log2(G));
	
	else
		ibit = N * ceil(log2(R));
	end
else
	fprintf('	 Return the number of additional bits needed for a given stage i of the CIC filter\n\n');
	fprintf('	 ibit = getb(i, R, N, CicType)\n\n');
	fprintf('		i 		: Current Stage - Integrator or Differentiator\n');
	fprintf('		R 		: CIC Rate change factor\n');
	fprintf('		N		: Total number of cascaded integrator stages\n');
	fprintf('		CicType	: when 0 , interpolator, when 1 integrator;\n');
	fprintf('		ibit	: additional bits needed for a given stage i of the CIC filter;\n');
end


