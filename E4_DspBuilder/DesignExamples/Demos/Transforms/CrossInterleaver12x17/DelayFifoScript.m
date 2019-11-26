% 
% DSP Builder (Version 2.1.0)
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

function [res] = DelayFifoScript(IntvlBlockName, symbol_width, Delay)

res =0;

s_Din 				= [IntvlBlockName '/Din'];
s_Dout				= [IntvlBlockName '/Dout'];
s_DPRam_Delay		= [IntvlBlockName '/DRB'];

set_param(IntvlBlockName,'LinkStatus','none');

set_param(s_Din,'bwl', num2str(symbol_width));
set_param(s_Dout,'bwl', num2str(symbol_width));
set_param(s_DPRam_Delay,'depth', num2str(Delay));
