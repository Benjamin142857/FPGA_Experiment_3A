%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	function fftplot(data,fs,color,N)
%
% 	data  		: input data sequence
% 	fs    		: sample rate
% 	color 		: Plot colors
% 	N     		: fft length
%
%   DSP Builder v2.0.0 - $Revision: #1 $ 
%	Copyright (C) 2001-2002 Altera Corporation
%
%$Header: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/DesignExamples/Demos/Filters/IIROrder2/fftplot.m#1 $
function fftplot(data,fs,color,N)

if(nargin==0)
 fprintf('Error using test : Not enough input arguments\n');
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
