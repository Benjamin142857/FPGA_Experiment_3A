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
% $Id: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/DesignExamples/Tutorials/HIL/EdgeDetection/ed_out_script.m#1 $
%

if (length(dir('TestImage.bmp'))>0)
		
	post_thresh_im  = gray_im;
	pre_thresh_im   = gray_im;
	
	if (length(simout) > ncls*nrws) && (length(simout1) > ncls*nrws)

		post_threshold  = uint8(simout);
		pre_threshold   = uint8(simout1);
		
		for i=1:nrws
		    for j=1:ncls
		      post_thresh_im(i,j) = post_threshold((i-1)*ncls+j);
		      pre_thresh_im(i,j) = pre_threshold((i-1)*ncls+j);        
		    end
		end
		  
		 
		figure(1);
		subplot(2,2,1);
		colormap('default');
		image(orig_im);
		title('Original - Color');
		  
		subplot(2,2,2);
		colormap(gray);
		image(gray_im./3.5); % Scale data to use full color map
		title('Original - Grayscale');
		
		subplot(2,2,3);
		colormap(gray);
		image(pre_thresh_im);
		title('Edge Detection - Prethreshold');
		%pause(1);
		
		
		subplot(2,2,4);
		colormap(gray);
		image(post_thresh_im);
		title('Edge Detection - Postthreshold');
		%pause(1);
	else
		alt_dspbuilder_error('Incomplete simulation. Unable to display the image.');
		disp(['  > Incomplete simulation. Unable to display the image.']);		
	end
else
	alt_dspbuilder_error('Unable to locate the image TestImage.bmp');
	disp(['  > Unable to locate the image TestImage.bmp']);
end;
