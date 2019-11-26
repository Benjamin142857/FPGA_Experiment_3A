function [detected_data, errors, output_decoder_c, input_upper_u] = SWTurboDecode( input_decoder_c, data, turbo_iterations, decoder_type, code_interleaver, pun_pattern, tail_pattern, g1, nsc_flag1, g2, nsc_flag2, num_engines, sldwin_size, varargin, sim_param)
% TurboDecode decodes a received PCCC sequence.  If input_decoder_c has
% multiple rows, then multiple codewords will be decoded (one for each row).
%
% The calling syntax is:
%     [detected_data, errors, output_decoder_c, [output_decoder_u] ] =
%                     SWTurboDecode( input_decoder_c, data, turbo_iterations, decoder_type,  ... 
%                          code_interleaver, pun_pattern, tail_pattern, g1, nsc_flag1, g2, ...
%                          nsc_flag2, num_engines, [input_decoder_u] )
%
%     detected_data = a row vector containing the detected data
%     errors = a column vector containing the number of errors per
%              iteration for all the codewords.
%     output_decoder_c = the extrinsic information of the code bits
%     output_decoder_u = the extrinsic information of the systematic bits (optional)
%
%     input_decoder_c = the decoder input, in the form of bit LLRs
%                       this could have multiple rows if the data is longer
%                       than the interleaver
%     data = the row vector of data bits (used to count errors and for early halting of iterative decoding)
%     turbo_iterations = the number of turbo iterations
%     decoder_type = the decoder type
%              = 0 For linear-log-MAP algorithm, i.e. correction function is a straght line.
%              = 1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y) ), i.e. correction function = 0.
%              = 2 For Constant-log-MAP algorithm, i.e. correction function is a constant.
%              = 3 For log-MAP, correction factor from small nonuniform table and interpolation.
%              = 4 For log-MAP, correction factor uses C function calls.
%              = 5 For scaling max-log-MAP, scaling factor = 0.75.
%     data = the row vector of data bits
%     code_interleaver = the turbo interleaver
%     pun_pattern = the puncturing pattern for all but the tail
%     tail_pattern = the puncturing pattern just for the tail
%     g1 = the first generator polynomial
%     nsc_flag1 = 0 if first encoder is RSC and 1 if NSC
%     g2 = the second generator polynomial
%     nsc_flag2 = 0 if second encoder is RSC and 1 if NSC
%	  num_engines = the number of parallel engines (windows)
%     [input_decoder_u] = the a priori information about systematic bits (optional input)
%
% determine some parameters
[N1,K1] = size( g1 );
[N2,K2] = size( g2 );

if (N1 ~= N2 || K1 ~= K2)
	error('Size of polynomial generators are different!');
end

% check interleaver length against data length
K_data = length( data );
K_interleaver = length( code_interleaver );
if ( rem( K_data, K_interleaver ) )
    error( 'The data length needs to be an integer multiple of the interleaver length' );
end
number_codewords = K_data/K_interleaver;
data_bits_per_frame = K_data/number_codewords;

% intialize error counter
errors = zeros( turbo_iterations, 1 );   

debug = 0;

if (debug)
	load 'input.mat';
	fid = fopen('swturbo.txt','a');
else
	data = reshape( data, K_interleaver, number_codewords)'; %'
	
	if ( length(varargin) >= 1 )   
	    input_upper_u = varargin;
	else
	    input_upper_u = zeros( number_codewords, data_bits_per_frame );
	end

	%save 'input.mat' data input_upper_u input_decoder_c;  
end

max_states = 2 ^ (K1-1);
num_windows = floor(data_bits_per_frame / sldwin_size); % + sign(mod(data_bits_per_frame,sldwin_size));

MAXLOG = 1e7;

% loop over each received frame
for codeword_index=1:number_codewords       
   
    % depuncture and split
    depunctured_output = Depuncture( input_decoder_c(codeword_index,:), pun_pattern, tail_pattern );
    input_upper_c = reshape( depunctured_output(1:N1,:), 1, N1*length(depunctured_output) );
    input_lower_c = reshape( depunctured_output(N1+1:N1+N2,:), 1, N2*length(depunctured_output) );
    
    input_beta1 = zeros(1, max_states*2*(num_windows+1));
    input_beta2 = input_beta1;
  
%  	fprintf('original data: '); dump_data(data);
    
    % decode
    for turbo_iter=1:turbo_iterations
        % fprintf( 'Turbo iteration = %d\n', turbo_iter );
        % Pass through upper decoder
        if ((sim_param.code_configuration ~= 4)&&(sim_param.code_configuration ~= 5))
       		[output_upper_u output_upper_c output_beta1] = SWSisoDecode( input_upper_u(codeword_index,:), input_upper_c, g1, nsc_flag1, decoder_type, num_engines, sldwin_size, input_beta1,2*turbo_iter-1 );
       	else  % UMTS
       		[output_upper_u output_upper_c output_beta1] = SWSisoDecode_umts( input_upper_u(codeword_index,:), input_upper_c, g1, nsc_flag1, decoder_type, num_engines, sldwin_size, input_beta1,2*turbo_iter-1 );
       	end
        
        % Interleave and extract extrinsic information
%        input_lower_u = Interleave( output_upper_u - input_upper_u(codeword_index,:), code_interleaver );
        input_lower_u = Interleave( output_upper_u, code_interleaver );
        input_beta1 = output_beta1;
 
        % Pass through lower decoder
        if ((sim_param.code_configuration ~= 4)&&(sim_param.code_configuration ~= 5))
	        [output_lower_u output_lower_c output_beta2] = SWSisoDecode( input_lower_u, input_lower_c, g2, nsc_flag2, decoder_type, num_engines, sldwin_size, input_beta2,2*turbo_iter);
       	else  % UMTS
	        [output_lower_u output_lower_c output_beta2] = SWSisoDecode_umts( input_lower_u, input_lower_c, g2, nsc_flag2, decoder_type, num_engines, sldwin_size, input_beta2,2*turbo_iter);
	    end
	    
        input_beta2 = output_beta2;

        if (decoder_type == 5)
            scaling_factor = 0.75;
        else
            scaling_factor = 1.0;
        end;                
        
        % count errors
        detected_data(codeword_index,:) = Deinterleave( (sign(output_lower_u+scaling_factor*input_lower_u)+1)/2, code_interleaver );
        error_positions = xor( detected_data(codeword_index,:), data(codeword_index,:) );       
        
        % exit if all the errors are corrected
        temp_errors = sum(error_positions);
%        dump_data(detected_data);
        
        % for debugging
        % fprintf('Iteration: %d, Errors: %d\n', turbo_iter, temp_errors );
        if (temp_errors==0)
            break;
        else
            errors(turbo_iter) = temp_errors + errors(turbo_iter);              
            % Interleave and extract extrinsic information
%            input_upper_u(codeword_index,:) = Deinterleave( output_lower_u - input_lower_u, code_interleaver );  
            input_upper_u(codeword_index,:) = Deinterleave( output_lower_u, code_interleaver );  
        end        
                             
    end         
    
    % Combine output_c and puncture
    % convert to matrices (each row is from one row of the generator)
    upper_reshaped = [ reshape( output_upper_c, N1, length(output_upper_c)/N1 ) ];
    lower_reshaped = [ reshape( output_lower_c, N2, length(output_lower_c)/N2 ) ];
    
    % parallel concatenate
    unpunctured_word = [upper_reshaped
        lower_reshaped];                     
    % repuncture
    output_decoder_c( codeword_index,:) = Puncture( unpunctured_word, pun_pattern, tail_pattern ); 
end

if (debug)
	fclose(fid);
end;
detected_data = reshape( detected_data', 1, K_data);


function dump_data(data)
fprintf('\n');
for i=1:length(data)
fprintf('%d',data(i));
end;
fprintf('\n');
