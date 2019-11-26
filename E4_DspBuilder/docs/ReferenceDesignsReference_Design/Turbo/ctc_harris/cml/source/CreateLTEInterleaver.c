/* file: CreateUmtsInterleaver.c

   Description: Produce an interleaver according to the UMTS spec.

   The calling syntax is:

		[alpha] = CreateUmtsInterleaver( K )

         alpha  = the interleaver in a length K vector 
		
         K  = the size of the interleaver 

   Copyright (C) 2005-2006, Matthew C. Valenti

   Last updated on June 10, 2006

   Function CreateUmtsInterleaver is part of the Iterative Solutions 
   Coded Modulation Library. The Iterative Solutions Coded Modulation 
   Library is free software; you can redistribute it and/or modify it 
   under the terms of the GNU Lesser General Public License as published 
   by the Free Software Foundation; either version 2.1 of the License, 
   or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
  
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/
#include <math.h>
#include <mex.h>
#include <matrix.h>
#include <stdlib.h>

/* library of functions */
#include "include/interleaver.h"

/* Input Arguments */
#define INPUT      prhs[0]

/* Output Arguments */
#define	OUTPUT	   plhs[0]

/* main function that interfaces with MATLAB */
void mexFunction(
	int		        nlhs,
	mxArray	        *plhs[],
	int		        nrhs,
	const mxArray	*prhs[] )
{
	int     DataLength;
    double	*output_p;
	int     *alpha_code; /* interleaver */
    int     *interleaver_input;	/* Temporary array used to initialize the interleaver. */
	int     i;

	static char msg_buf[256];
	bool   is_DataLength_supported_by_LTE_interleaver = false;

	/* Check for proper number of arguments */
	if (nrhs < 1) {
		mexErrMsgTxt("[alpha] = CreateLTEInterleaver( K )");
	} else if (nlhs > 2) {
		mexErrMsgTxt("[alpha] = CreateLTEInterleaver( K )");
	}	
	
	/* initialize the input data */
	DataLength   = (int) *mxGetPr(INPUT);

	if ( (DataLength < 40)|( DataLength > 8192) )
		mexErrMsgTxt("CreateLTEInterleaver: Input must be between 40 and 8192");

	/* Create the interleaver */
	alpha_code = calloc( DataLength, sizeof(int) );
	interleaver_input = calloc( DataLength, sizeof(int) );
	for (i=0;i<DataLength;i++)
		interleaver_input[i] = i;
	
	is_DataLength_supported_by_LTE_interleaver = CreateLTEInterleaver( DataLength, interleaver_input, alpha_code );

	if ( !is_DataLength_supported_by_LTE_interleaver )
	{
		sprintf(msg_buf, "CreateLTEInterleaver: Block size %d isn't supported by LTE");
		mexErrMsgTxt(msg_buf);
	}

	/* Output encoded data */
	OUTPUT = mxCreateDoubleMatrix(1, DataLength, mxREAL);
	output_p = mxGetPr(OUTPUT);

	for (i=0;i<DataLength;i++) {
		output_p[i] = alpha_code[i];
	}

	free( alpha_code );
	free( interleaver_input );

	return;
}
