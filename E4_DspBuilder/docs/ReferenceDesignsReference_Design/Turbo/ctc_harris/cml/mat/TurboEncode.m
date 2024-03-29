function codeword = TurboEncode( data, code_interleaver, pun_pattern, tail_pattern, g1, nsc_flag1, g2, nsc_flag2 )
% TurboEncode encodes a data sequence.  If the data length is an integer
% multiple of the interleaver length, then multiple codewords are returned,
% (one per row of the codeword matrix).
%
% The calling syntax is:
%     codeword = TurboEncode( data, code_interleaver, pun_pattern, tail_pattern, g1, nsc_flag1, g2, nsc_flag2 )
%
%     codeword = the codeword generated by the encoder,
%                will contain multiple rows if the data is longer than the
%                interleaver
%
%     data = the row vector of data bits
%     code_interleaver = the turbo interleaver
%     pun_pattern = the puncturing pattern for all but the tail
%     tail_pattern = the puncturing pattern just for the tail
%     g1 = the first generator polynomial
%     nsc_flag1 = 0 if first encoder is RSC and 1 if NSC
%     g2 = the second generator polynomial
%     nsc_flag2 = 0 if second encoder is RSC and 1 if NSC
%
% Copyright (C) 2005, Matthew C. Valenti
%
% Last updated on Dec. 13, 2005
%
% Function TurboEncode is part of the Iterative Solutions Coded Modulation
% Library (ISCML).  
%
% The Iterative Solutions Coded Modulation Library is free software;
% you can redistribute it and/or modify it under the terms of 
% the GNU Lesser General Public License as published by the 
% Free Software Foundation; either version 2.1 of the License, 
% or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

% determine the size of the two generators
[N1,K1] = size( g1 );
[N2,K2] = size( g2 );

% in the future, we will allow constituent codes with different constraint lengths
if ( K1 ~= K2 )
    error( 'The constraint lengths of the two PCCC constituent codes must be indentical' );
end

% check interleaver length against data length
K_data = length( data );
K_interleaver = length( code_interleaver );
if ( rem( K_data, K_interleaver ) )
    error( 'The data length needs to be an integer multiple of the interleaver length' );
end
number_codewords = K_data/K_interleaver;

data = reshape( data, K_interleaver, number_codewords)';

for codeword_index=1:number_codewords    
    % Encode in parallel (fixed on 2-1-06)
    upper_output = ConvEncode( data(codeword_index,:), g1, nsc_flag1 );   
    lower_output = ConvEncode( Interleave( data(codeword_index,:), code_interleaver), g2, nsc_flag2 );
    
    % convert to matrices (each row is from one row of the generator)
    upper_reshaped = [ reshape( upper_output, N1, length(upper_output)/N1 ) ];
    lower_reshaped = [ reshape( lower_output, N2, length(lower_output)/N2 ) ];
    
    % parallel concatenate
    unpunctured_word = [upper_reshaped
        lower_reshaped];
    %size(unpunctured_word)
    %size(pun_pattern)
    %size(tail_pattern)
    %pun_pattern
    %tail_pattern
    %nsc_flag1
    %nsc_flag2
    codeword(codeword_index,:) = Puncture( unpunctured_word, pun_pattern, tail_pattern );    
    
end
