% 
% DSP Builder (Version 2.1.1)
% Quartus II development tool and MATLAB/Simulink Interface
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
[Num,Den] = butter(2,0.4);
figure(1);
freqz(Num,Den);
figure(2);
grpdelay(Num,Den);