if (length(dir('color.bmp'))>0)
   
	post_thresh_im  = gray_im;

    % load the image data from the mat file.
    load('simout');
    simout = simout(2,:);
    
	if (length(simout) > ncls*nrws)
        
		post_threshold  = uint8(simout);
		
		for i=1:nrws
		    for j=1:ncls
		      post_thresh_im(i,j) = post_threshold((i-1)*ncls+j);
		    end
		end
		  
		 
		figure(1);
		subplot(3,1,1);
		colormap('default');
		image(orig_im);
		title('Original - Color');
		  
		subplot(3,1,2);
		colormap(gray);
		image(gray_im./3.5); % Scale data to use full color map
		title('Original - Grayscale');
		
		subplot(3,1,3);
		colormap(gray);
		image(post_thresh_im);
		title('Edge Detection');
		%pause(1);
	else
		warndlg('Incomplete simulation. Unable to display the image.', 'Edge Detector');
		disp(['  > Incomplete simulation. Unable to display the image.']);		
	end
else
    warndlg('Unable to locate the image color.bmp', 'Edge Detector');
	disp(['  > Unable to locate the image color.bmp']);
end;
