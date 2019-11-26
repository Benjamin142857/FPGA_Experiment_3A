
if (length(dir('color.bmp'))>0)

	% read the image color.bmp
	orig_im= imread('color.bmp', 'bmp');
	
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
	warndlg('Unable to locate the image color.bmp', 'Edge Detector');
	disp(['  > Unable to locate the image color.bmp']);
end;

