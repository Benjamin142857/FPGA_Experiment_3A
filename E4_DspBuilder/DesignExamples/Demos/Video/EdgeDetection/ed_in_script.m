% 
% DSP Builder (Version 2.2.0)
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
% $Id: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/DesignExamples/Demos/Video/EdgeDetection/ed_in_script.m#1 $
%

if (length(dir('TestImage.bmp'))>0)

	% read the image TestImage.bmp
	orig_im= imread('TestImage.bmp', 'bmp');
	
	% convert to gray scale
	[nrws ncls colr] = size(orig_im);
	dbl=double(orig_im);
	gray_im      = zeros(nrws, ncls);
	gray_factors = [0.3; 0.59; 0.11];
	for j=1:ncls
	    for i=1:nrws
	        gray_im(i,j)= [dbl(i,j,1) dbl(i,j,2) dbl(i,j,3)] * gray_factors ;
	    end
	end
	
	% linearized array
	r1 = double(gray_im)+1;
	t = 1:ncls*nrws;
	simin.signals.values = (1:ncls*nrws)';
	rst_in.signals.values = (1:ncls*nrws)';
	simin.time = t;
	rst_in.time = t;
	for i=1:nrws
	    for j=1:ncls
	          simin.signals.values((i-1)*ncls+j) = r1(i,j);
	          rst_in.signals.values((i-1)*ncls+j) = 0;
	  end
	end
	rst_in.signals.values(1) = 1;

else
	alt_dspbuilder_error('Unable to locate the image TestImage.bmp');
	disp(['  > Unable to locate the image TestImage.bmp']);
end;

