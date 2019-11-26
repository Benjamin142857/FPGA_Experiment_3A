% 
% DSP Builder (Version 2.2.0)
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
% $Id: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/DesignExamples/Demos/Transforms/Cordic/get_sincos_fxp.m#1 $
%
%

function [x,y] = get_sincos_fxp(Angle, precision)

%Angle between -90 and +90 degree
 
InitialAngle = Angle*pi/180;
ScalingFactor = (2^(precision-1))-1;
InitialAngleFix = round(InitialAngle*ScalingFactor)

K =1.0;
KFix =1.0;
for i=1:precision
    cordic_table{i}.k = K;
    cordic_table{i}.kfix = KFix;
    cordic_table{i}.phase_rads = round(atan(K)*ScalingFactor);
    K=0.5*K;
    KFix=2*KFix;
end;

%Initial Value when computing sin/cos
x=round(0.60725293510314*ScalingFactor);
y=0;
acc_phase_rads=InitialAngleFix;

for i=1:precision

    K          			= cordic_table{i}.k;
    phase_rads 			= cordic_table{i}.phase_rads;
 	KFix				= cordic_table{i}.kfix;
 	
    xi=x;
    yi=y;
    
    if acc_phase_rads<0
      x 				= fix(xi + yi/KFix);
      y 				= fix(yi - xi/KFix);
      acc_phase_rads 	= fix(acc_phase_rads+phase_rads);
    else
      x 				= fix(xi - yi/KFix);
      y 				= fix(yi + xi/KFix);
      acc_phase_rads 	= fix(acc_phase_rads-phase_rads);
    end;
end;
