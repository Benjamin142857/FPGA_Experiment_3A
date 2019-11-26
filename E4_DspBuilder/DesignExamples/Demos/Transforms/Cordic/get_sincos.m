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
% $Id: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/DesignExamples/Demos/Transforms/Cordic/get_sincos.m#1 $
%
%

function [x,y] = get_sincos(Angle, precision)

%Angle between -90 and +90 degree
 
% precision bits conversion
InitialAngle = Angle*pi/180; %Coneversion to radian

K =1.0;
for i=1:precision
    cordic_table{i}.k = K;
    cordic_table{i}.phase_rads = atan(K);
    K=0.5*K;
end;

%Initial Value when computing sin/cos
x=0.60725293510314;
y=0;
acc_phase_rads=InitialAngle;

for i=1:precision
    K          			= cordic_table{i}.k;
    phase_rads 			= cordic_table{i}.phase_rads;
 
    xi=x;
    yi=y;
    
    if acc_phase_rads<0
      x 				= xi + yi*K;
      y 				= yi - xi*K;
      acc_phase_rads 	= acc_phase_rads+phase_rads;
%	disp(['pos x=' num2str(x) ' y=' num2str(y) ' z=' num2str(acc_phase_rads) ' k=' num2str(K) ' phase_rads=' num2str(phase_rads)]);
    else
      x 				= xi - yi*K;
      y 				= yi + xi*K;
      acc_phase_rads 	= acc_phase_rads-phase_rads;
%	disp(['neg x=' num2str(x) ' y=' num2str(y) ' z=' num2str(acc_phase_rads) ' k=' num2str(K) ' phase_rads=' num2str(phase_rads)]);
    end;
end;

disp(['cos = ' num2str(cos(InitialAngle)) ' vs ' num2str(x)]);
disp(['sin = ' num2str(sin(InitialAngle)) ' vs ' num2str(y)]);
