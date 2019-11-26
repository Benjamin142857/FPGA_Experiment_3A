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

function plot_fft(signal_name, plot_title, fsamp)

tol = 1e-7;

data = signal_name(304:1023);
freqdat = fft(data);
absdat = abs(freqdat);
maxdat = max (absdat);
logdat = 20*log10((absdat / maxdat)+tol);
sz = size(data);
numpts = max(sz);

figure;
freq_res = fsamp/numpts;
xline = linspace (0, ( (fsamp/2)- freq_res ), round(numpts/2) );
plot (xline, logdat(1: round(numpts/2) ), 'r');

title (plot_title);
grid on;
zoom on;

xlabel ('Frequency');
ylabel ('Magnitude - dB');