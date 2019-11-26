% 
% DSP Builder (Version 2.2.1)
% Quartus II development tool and MATLAB/Simulink Interface
% 
% Legal Notice: © 2001 Altera Corporation. All rights reserved.  Your use of Altera 
% Corporation's design tools, logic functions and other software and tools, and its 
% AMPP partner logic functions, and any output files any of the foregoing 
% (including device programming or simulation files), and any associated 
% documentation or information are expressly subject to the terms and conditions 
% of the Altera Program License Subscription Agreement, Altera MegaCore Function 
% License Agreement, or other applicable license agreement, including, without 
% limitation, that your use is for the sole purpose of programming logic devices 
% manufactured by Altera and sold by Altera or its authorized distributors.  
% Please refer to the applicable agreement for further details.
%  
% $Id: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/DesignExamples/Demos/Filters/CicFilter/CicPLL/fftplot.m#1 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	function fftplot(data,fs,color,N)
%
% 	data  		: input data sequence
% 	fs    		: sample rate
% 	color 		: Plot colors
% 	N     		: fft length
%
function fftplot(data,fs,color,N)
if(nargin==0)
 fprintf('\n\tfftplot useage:\n\n');
 fprintf('\t\tfftplot(data)\nor\n');
 fprintf('\t\tfftplot(data,fs)\nor\n');
 fprintf('\t\tfftplot(data,fs,color,N)\n');
return;
elseif (nargin==1)
 N=length(data);
 color = 'r';
 fs = 1;
elseif (nargin==2)
 N=length(data);
 color = 'r';
end

data = data(1:N);
S=abs(fft(data));
S = S./max(S);
S = 20*log10(S+1e-10);

if (fs>1)
	xvals = linspace(0,floor(fs/2)-floor((fs/N)),floor(N/2));
else
	xvals = [0:1/N:1];
end

figure;    
if (fs>1)
	plot(xvals(1:floor(N/2)),S(1:floor(N/2)),color), grid on,axis([0,floor(fs/2)-1,-150,20]);
	xlabel('Frequency (Hz)');
	ylabel('Magnitude (dB)');
else
	plot(xvals(1:floor(N/2)),S(1:floor(N/2)),color), grid on,axis([0,0.5,-150,20]);
	xlabel('Normalized Frequency');
	ylabel('Magnitude (dB)');
end;
