% ViterbiDecode performs soft-in/hard-out decoding for a convolutional code using the Viterbi algorithm
%
%  The calling syntax is:
%      [output_u] = ViterbiDecode( input_c, g_encoder, [code_type] )
%
%      output_u = hard decisions on the data bits (0 or 1)
%
%      Required inputs:
%	   input_c = LLR of the code bits (based on channel observations)
% 	   g_encoder = generator matrix for convolutional code
%	              (If RSC, then feedback polynomial is first)
%	  
%	   Optional inputs:
%	   code_type = 0 for RSC outer code (default)
%	             = 1 for NSC outer code
%   
% Copyright (C) 2005-2006, Matthew C. Valenti
%
% Last updated on Mar. 14, 2006
%
% Function ViterbiDecode is part of the Iterative Solutions 
% Coded Modulation Library. The Iterative Solutions Coded Modulation 
% Library is free software; you can redistribute it and/or modify it 
% under the terms of the GNU Lesser General Public License as published 
% by the Free Software Foundation; either version 2.1 of the License, 
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
