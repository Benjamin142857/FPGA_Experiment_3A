/* file: SWSisoDecode_umts_fxp.c

   Description: Soft-in/soft-out decoding algorithm for a convolutional code

   The calling syntax is:

      [output_u, output_c] = SWSisoDecode(input_u, input_c, g_encoder, [code_type], [dec_type] )

      output_u = LLR of the data bits
	  output_c = LLR of the code bits

      Required inputs:
	  input_u = APP of the data bits
	  input_c = APP of the code bits
	  g_encoder = generator matrix for convolutional code
	              (If RSC, then feedback polynomial is first)
	  
	  Optional inputs:
	  code_type = 0 for RSC outer code (default)
	            = 1 for NSC outer code
	  dec_type = the decoder type:
			= 0 For linear approximation to log-MAP (DEFAULT)
			= 1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y) )
			= 2 For Constant-log-MAP algorithm
			= 3 For log-MAP, correction factor from small nonuniform table and interpolation
			= 4 For log-MAP, correction factor uses C function calls (slow)  
   
   Function SWSisoDecode is part of the Iterative Solutions 
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

#include "pSW_sisoDecoder_umts_fxp.h"

extern "C" {
/* library of functions */
#include <mex.h>
#include "convolutional_fxp.h"

/* Input Arguments */
#define INPUT_U     prhs[0]
#define INPUT_C     prhs[1]
#define GENENCODER  prhs[2]
#define CODETYPE    prhs[3]
#define DECTYPE     prhs[4]
#define NUM_SUBBLK  prhs[5]
#define SUBBLK_SIZE prhs[6]
#define BETA        prhs[7]
#define ITER        prhs[8]
#define BITWIDTH	prhs[9]

/* Output Arguments */
#define OUTPUT_U    plhs[0]
#define OUTPUT_C    plhs[1] 
#define OUTPUT_B    plhs[2] 
#define OUTPUT_LLR  plhs[3] 

/* main function that interfaces with MATLAB */
void mexFunction(
				 int            nlhs,
				 mxArray       *plhs[],
				 int            nrhs,
				 const mxArray *prhs[] )
{
	double	*input_u, *input_c, *alpha_beta_prev, *g_array, *bw_array; /* input arrays */
	double  *output_u_p, *output_c_p, *output_b_p, *output_llr_p; /* output arrays */
	int      DataLength, CodeLength, i, j, index;
	int      subs[] = {1,1};
	int     *g_encoder;
	int		*bit_width;
	int		 nn, KK, mm, max_states, code_type, dec_type, iteration, bw_size;

	vector<data_fix_type> input_c_fxp;
	vector<data_fix_type> output_c_fxp;
	vector<data_fix_type> input_u_fxp,output_u_fxp;
	vector<soft_fix_type> output_b_fxp,output_llr_fxp;
	vector<soft_fix_type> alpha_beta_prev_fxp;

	int     *out0, *out1, *state0, *state1;

#ifdef _DEBUG
	bool  overflow_flag = false;
	bool  quantization_flag = false;
#endif

	/* Variables used for implemente sliding/parrael windows */
	int     num_engines;  /* number of parallel windows*/
	int     sldwin_size;  /* the size of parallel windows*/
	int     BetaLength;

	/* default values */
	code_type = 0;
	dec_type  = 0;
	num_engines = 0;

	/* Check for proper number of arguments */
	if (nrhs < 3 ) {
		mexErrMsgTxt("Usage: [output_u, output_c] = SWSisoDecode_umts(input_u, input_c, g_encoder, code_type, decoder_type )");
	} else {
		/* first two inputs are the LLRs of the data and code bits */
		input_u = mxGetPr(INPUT_U);	
		input_c = mxGetPr(INPUT_C);

		/* third input specifies the code */
		g_array = mxGetPr(GENENCODER);
		nn = mxGetM(GENENCODER);
		KK = mxGetN(GENENCODER);
		mm = KK - 1;	
		max_states = 1 << mm;			/* 2^mm */
		
		DataLength = mxGetN(INPUT_U); /* number of data bits */
		CodeLength = mxGetN(INPUT_C); /* number of code bits */

		/* make sure these agree */
		if ( CodeLength != nn*(DataLength+mm) ) 
			mexErrMsgTxt( "SWSisoDecode_umts: Length of input_u and input_c don't agree" );

		/* 10th input is the bitwidth info */
		bw_array  = mxGetPr(BITWIDTH);
		bw_size = mxGetN(BITWIDTH);
		bit_width = (int *)calloc(bw_size, sizeof(int) );
		for(j = 0; j < bw_size; j++)
		{
			bit_width[j] = (int) (bw_array[j]);
		}

		// Set the context for data and soft values
#if (DYNAMIC_BW)
		sc_fxtype_params param_data(bit_width[0], bit_width[0]-bit_width[1], SC_TRN, SC_WRAP);
		sc_fxtype_context cont_data(param_data);
#endif

		input_c_fxp.resize(CodeLength);
		for (i=0;i<CodeLength;i++)
		{
			input_c_fxp[i] = input_c[i];

#ifdef _DEBUG
			if (input_c_fxp[i].quantization_flag())
			{
				quantization_flag = true;
			}
			if (input_c_fxp[i].overflow_flag())
			{
				overflow_flag = true;
			}
#endif
		}

#if (DYNAMIC_BW)
		sc_fxtype_params param_soft(bit_width[2], bit_width[2]-bit_width[3], SC_TRN, SC_WRAP);
		sc_fxtype_context cont_soft(param_soft);
#endif

		/* convert the inputs into float */			
		input_u_fxp.resize(DataLength);
		for (i=0;i<DataLength;i++)
		{
			input_u_fxp[i] = input_u[i];

#ifdef _DEBUG
			if (input_u_fxp[i].quantization_flag())
			{
				quantization_flag = true;
			}
			if (input_u_fxp[i].overflow_flag())
			{
				overflow_flag = true;
				double b = input_u_fxp[i].to_double();
			}
#endif
		}

		/* Convert code polynomial to binary */
		g_encoder = (int *)calloc(nn, sizeof(int) );

		for (i = 0;i<nn;i++) {
			subs[0] = i;
			for (j=0;j<KK;j++) {
				subs[1] = j;
				index = mxCalcSingleSubscript(GENENCODER, 2, subs);
				if (g_array[index] != 0) {
					g_encoder[i] = g_encoder[i] + (1 << (KK-j-1)); 
				}
			}
			/* mexPrintf("   g_encoder[%d] = %o\n", i, g_encoder[i] ); */
		}

		/* 4th input is the type of code */
		code_type   = (int) *mxGetPr(CODETYPE);

		/* 5th input is the decoder type */
		dec_type  = (int) *mxGetPr(DECTYPE);

		/* 6th input is the num_enginese */
		num_engines  = (int) *mxGetPr(NUM_SUBBLK);

		/* 7th input  is the sldwin_size */
		sldwin_size  = (int) *mxGetPr(SUBBLK_SIZE);

		/* 8th input is the beta values */
		alpha_beta_prev  = mxGetPr(BETA);
		BetaLength = mxGetN(BETA);

		/* 9th input is the iteration */
		iteration  = (int) *mxGetPr(ITER) - 1;
	}

	if (nlhs  < 3 || nrhs < 10) {
		mexErrMsgTxt("Usage: [output_u, output_c, output_beta] = SWSisoDecode_umts(input_u, input_c, g_encoder, code_type, decoder_type, num_engines, sldwin_size, beta )" );
	} 

#if (DYNAMIC_BW)
		sc_fxtype_params param_data(bit_width[0], bit_width[0]-bit_width[1], SC_TRN, SC_WRAP);
		sc_fxtype_context cont_data(param_data);
#endif

	/* the outputs */		
	OUTPUT_C = mxCreateDoubleMatrix(1, CodeLength, mxREAL );
	output_c_p = mxGetPr(OUTPUT_C);	
	output_c_fxp.resize(CodeLength);

#if (DYNAMIC_BW)
	sc_fxtype_params param_soft(bit_width[2], bit_width[2]-bit_width[3], SC_TRN, SC_WRAP);
	sc_fxtype_context cont_soft(param_soft);
#endif
	OUTPUT_U = mxCreateDoubleMatrix(1, DataLength, mxREAL );
	output_u_p = mxGetPr(OUTPUT_U);	
	output_u_fxp.resize(DataLength);
	
	OUTPUT_LLR = mxCreateDoubleMatrix(1, DataLength, mxREAL );
	output_llr_p = mxGetPr(OUTPUT_LLR);	
	output_llr_fxp.resize(DataLength);

	OUTPUT_B = mxCreateDoubleMatrix(1, BetaLength, mxREAL );
	output_b_p = mxGetPr(OUTPUT_B);
	output_b_fxp.resize(BetaLength);

	/* create appropriate transition matrices */
	out0 = (int *)calloc( max_states, sizeof(int) );
	out1 = (int *)calloc( max_states, sizeof(int) );
	state0 = (int *)calloc( max_states, sizeof(int) );
	state1 = (int *)calloc( max_states, sizeof(int) );

	if ( code_type ) {
		nsc_transit( out0, state0, 0, g_encoder, KK, nn );
		nsc_transit( out1, state1, 1, g_encoder, KK, nn );
	} else {
		rsc_transit( out0, state0, 0, g_encoder, KK, nn );
		rsc_transit( out1, state1, 1, g_encoder, KK, nn );
	}

	alpha_beta_prev_fxp.resize( BetaLength );

	for (j = 0; j < BetaLength; j++) {
		alpha_beta_prev_fxp[j] = alpha_beta_prev[j];

#ifdef _DEBUG
		if (alpha_beta_prev_fxp[j].quantization_flag())
			{
				quantization_flag = true;
			}
			if (alpha_beta_prev_fxp[j].overflow_flag())
			{
				overflow_flag = true;
			}
#endif
	}

	/* Run the fixed-point Parallel Sliding window SISO algorithm */

	pSW_sisoDecoder_umts_fxp siso ( &output_u_fxp, &output_c_fxp, &output_b_fxp, &output_llr_fxp, out0, state0, out1, state1,
		input_u_fxp, input_c_fxp, KK, nn, DataLength, dec_type, num_engines, sldwin_size, 
		alpha_beta_prev_fxp, iteration, bit_width, bw_size);
	
	siso.do_work();

	/* cast to outputs */

	for (j = 0; j < DataLength; j++) {
		output_u_p[j] = output_u_fxp[j].to_double();
	}

	for (j = 0; j < DataLength; j++) {
		output_llr_p[j] = output_llr_fxp[j].to_double();
	}

	for (j = 0; j < CodeLength; j++) 
	{
		output_c_p[j] = output_c_fxp[j].to_double();
	}

	for (j = 0; j < BetaLength; j++) {
		output_b_p[j] = output_b_fxp[j].to_double();
	}
		
	/* Clean up memory */
	output_u_fxp.clear();
	output_b_fxp.clear();
	output_c_fxp.clear();
	output_llr_fxp.clear();
	input_u_fxp.clear();
	input_c_fxp.clear();
	alpha_beta_prev_fxp.clear();
	free( out0 );
	free( out1 );
	free( state0 );
	free( state1 );
	free( g_encoder );
	free( bit_width );

	return;
}
} // end of extern "C"