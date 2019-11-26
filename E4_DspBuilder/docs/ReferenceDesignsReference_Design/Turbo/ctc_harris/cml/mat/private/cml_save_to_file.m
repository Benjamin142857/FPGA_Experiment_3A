function [ ] = cml_save_to_file( data, filename, bwr )
% cml_save_to_file Write test data to a file
%   This function is used for test vector generation.

try
    fid = fopen(filename,'at');
    
    if (fid == -1)
        error(sprintf('Error to open file %s', filename));
    end;

    in_data = fix(data .* (2^bwr));

    % look at the dimensions of the input data, print to file
    rows = size(data,1);
    cols = size(data,2);

    for i = 1:rows
        for j= 1:cols
            fprintf(fid, '%d', in_data(i,j));
            if (j<cols)
             fprintf(fid, ' ');
           end
            
        end;
        fprintf(fid, '\n');
    end;

    fclose(fid);
catch
    rethrow(lasterror);
end;
