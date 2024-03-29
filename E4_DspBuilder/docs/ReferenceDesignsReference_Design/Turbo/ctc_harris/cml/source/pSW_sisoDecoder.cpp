/* File pSW_sisoDecoder.cpp

*/

#include "convolutional.h"
#include "maxstar.h"
#include "pSW_sisoDecoder.h"

/* Class pSW_sisoDecoder

  Description: Uses the (max)-log-MAP algorithm to perform soft-input, soft-output
  decoding of a convolutional code.

	Input parameters:
		out0[]		The output bits for each state if input is a 0 (generated by rsc_transit).
		state0[]	The next state if input is a 0 (generated by rsc_transit).
		out1[]		The output bits for each state if input is a 1 (generated by rsc_transit).
		state1[]	The next state if input is a 1 (generated by rsc_transit).
		input_c[]	The received signal in LLR-form. Must be in form r = 2*a*y/(sigma^2).
		input_u[]	The APP input.  This is the extrinsic output from the other decoder.
		KK			The constraint length of the convolutional code.
		nn      
		LL			The number of data bits.
		DecOpts		Decoder termination option = 0 for unterminated and = 1 for terminated.
		DecoderType	    = 0 Linear approximation to log-MAP correction function.
						= 1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y) )
						= 2 For Constant-log-MAP algorithm
						= 3 For log-MAP, correction factor using piecewise linear approximation
						= 4 For log-MAP, correction factor uses C function calls
		iteration         current number of half iteration

	Output parameters:
		output_c[]		The log-likelihood ratio of each data bit.
		output_u[]		The extrinsic information of each data bit.
	
  This function is used by turbo_decode()   
  
*/

pSW_sisoDecoder::pSW_sisoDecoder
(
	double  *output_u,
	double  *output_c,
	double  *output_b,
	int    *out0, 
	int    *state0, 
	int    *out1, 
	int    *state1,
	float  *input_u,
	float  *input_c,
	int    KK,
	int    nn,
	int    LL,
	int	   DecoderType,
	int    num_subblocks,
	int    subblock_size,
	double *alpha_beta,
	int    iteration
)
: debug(false)
{
	this->output_u        =		output_u;
	this->output_b        =  	output_b;
	this->output_c        =  	output_c;
	this->out0            =  	out0;
	this->state0          =  	state0;
	this->out1            =  	out1;
	this->state1          =  	state1;
	this->input_u         =  	input_u;
	this->input_c         =  	input_c;
	this->nn              =  	nn ;
	this->frame_size      =  	LL ;
	this->DecoderType     =  	DecoderType;
	this->num_subblocks   =  	num_subblocks;
	this->subblock_size   =  	subblock_size;
	this->alpha_beta_prev =  	alpha_beta;
	this->iteration		  =		iteration;

	/* derived constants */
	mm = KK-1;
	max_states = 1 << mm;			/* 2^mm */
	number_symbols = 1 << nn;	    /* 2^nn */
	
	rev_out0.resize(max_states);
	rev_state0.resize(max_states);
	rev_out1.resize(max_states);
	rev_state1.resize(max_states);
	delta_num.resize(max_states);
	delta_den.resize(max_states);

	for (int state = 0; state < max_states; state++)
	{
		rev_state0[state0[state]] = state;
		rev_state1[state1[state]] = state;
		rev_out0[state0[state]] = out0[state];
		rev_out1[state1[state]] = out1[state];
	}

	sub_frame_size = frame_size/num_subblocks;
	last_window_size = sub_frame_size%subblock_size;

	if (last_window_size == 0)
	{
		num_windows = sub_frame_size/subblock_size;
		last_window_size = subblock_size;
	}
	else
	{
		num_windows = sub_frame_size/subblock_size + 1;
	}

	/* initialize internal arrays */
	metric_c.resize(num_subblocks);
	beta.resize(num_subblocks);
	alpha.resize(num_subblocks);
	alpha_prime.resize(num_subblocks);
	num_llr_c.resize(num_subblocks);
	den_llr_c.resize(num_subblocks);
	num_llr_u.resize(num_subblocks);
	den_llr_u.resize(num_subblocks);

	for (int i = 0; i < num_subblocks; i++)
	{
		metric_c[i].resize(number_symbols,0);
		beta[i].resize((subblock_size+1)*max_states,0);
		alpha[i].resize(max_states,0);
		alpha_prime[i].resize(max_states,0);
		num_llr_c[i].resize(nn,-MAXLOG);
		den_llr_c[i].resize(nn,-MAXLOG);
	}

/*	ifstream fin_u("input_u.txt");  
	ifstream fin_c("input_c.txt"); 
	for (int i = 0; i < frame_size; i++)
	{
		fin_u >> input_u[i];
	}

	for (int i = 0; i < nn*(frame_size+mm); i++)
	{
		fin_c >> input_c[i];
	}
*/

#ifdef _DEBUG
	if(iteration == 0)
		fout_debug.open("fout_debug.txt");
#endif
}

pSW_sisoDecoder::~pSW_sisoDecoder()
{
	for (int i = 0; i < num_subblocks; i++)
	{
		metric_c[i].clear();
		beta[i].clear();
		alpha[i].clear();
		alpha_prime[i].clear();
		num_llr_c[i].clear();
		den_llr_c[i].clear();
	}

#ifdef _DEBUG
	if (iteration == 0)
		fout_debug.close();
#endif
	rev_out0.clear();
	rev_state0.clear();
	rev_out1.clear();
	rev_state1.clear();
	delta_num.clear();
	delta_den.clear();

	metric_c.clear();
	beta.clear();
	alpha.clear();
	alpha_prime.clear();
	num_llr_c.clear();
	den_llr_c.clear();
	num_llr_u.clear();
	den_llr_u.clear();
}

double pSW_sisoDecoder::max_star
(
	double delta1,
	double delta2
)
{
	float (*max_star_func[])(float, float) =
	{ 
		&max_star0, &max_star1, &max_star2, &max_star3, &max_star4, &max_star1
	};

	return (double)((max_star_func[DecoderType])(delta1,delta2));
}

void pSW_sisoDecoder::update_block_beta(int k, int p, int s)
{
	double delta1, delta2;

	float app_in = (k < frame_size) ? input_u[k] : 0;

	/* step through all states */
	for (int state=0; state < max_states; state++ ) 
	{
		/* data 0 branch */
		delta1 = beta[p][(s+1)*max_states + state0[ state ]] + metric_c[p][ out0[ state ] ];
		
		/* data 1 branch */
		delta2 = beta[p][(s+1)*max_states + state1[ state ]] + metric_c[p][ out1[ state ] ] + app_in;
		
		/* update beta */
		beta[p][s*max_states + state ] = max_star(delta1, delta2);							
	}	
}

/* normalize alpha */
void pSW_sisoDecoder::update_alpha_prime(int p)
{
	int state;

	alpha_prime[p][0] = 0;
	for (state = 1; state < max_states; state++)
	{
		alpha_prime[p][state] = alpha[p][state] - alpha[p][0];
	}
}

/* normalize beta */
void pSW_sisoDecoder::normalize_beta(int p, int s)
{
	/* normalize beta */
	for (int state = 1; state < max_states; state++)
		beta[p][s*max_states + state] -= beta[p][s*max_states];

	beta[p][s*max_states] = 0;
}

void pSW_sisoDecoder::update_branch_metric(int k, int p)
{
	/* precompute all possible branch metrics */
	for (int i=0; i < number_symbols; i++)
		metric_c[p][i] = Gamma( input_c+nn*k, i, nn );
}

void pSW_sisoDecoder::compute_block_alpha(int k, int p)
{
	/* assign inputs */
	float app_in = (k < frame_size) ? input_u[k] : 0;


	double delta1, delta2;

	/* step through all states and find alpha */
	for (int state = 0; state < max_states; state++ ) {		
		/* Data 0 branch */
		delta1 = alpha_prime[p][ rev_state0[ state ] ] + metric_c[p][ rev_out0[ state ] ];

		/* Data 1 branch */
		delta2 = alpha_prime[p][ rev_state1[state]] + metric_c[p][ rev_out1[ state ] ] + app_in;

		alpha[p][ state ] = max_star(delta1, delta2);		
	}
}


void pSW_sisoDecoder::compute_llr(int k,int p, int s)
{
	int state;
	int symbol0, symbol1;	/* Symbols associated with data 0 and data 1 */
	float app_in;

	/* assign inputs */
	app_in = (k-1 < frame_size) ? input_u[k-1] : 0;

		/* assign inputs */
	if(k < frame_size)
		app_in = input_u[k];

	/* compute the LLRs */	
	for (state=0;state<max_states;state++)  {
		symbol0 = out0[state];
		symbol1 = out1[state];
		
		/* data 0 branch (departing) */
		delta_den[state] = alpha_prime[p][state] + metric_c[p][ symbol0 ] + beta[p][(s+1)*max_states+state0[state]];

		/* data 1 branch (departing) */
		delta_num[state] = alpha_prime[p][state] + metric_c[p][ symbol1] + beta[p][(s+1)*max_states+state1[state]] + app_in;
	}

	int num_states = max_states/2;

	while(num_states > 1)
	{
		for(int i = 0; i < num_states; i++)
		{
			delta_den[i] = max_star(delta_den[2*i],delta_den[2*i+1]);
			delta_num[i] = max_star(delta_num[2*i],delta_num[2*i+1]);
		}
		num_states /= 2;
	}

	/* den_llr and num_llr are used to compute the LLR and extrinsic info */
	den_llr_u[p] = max_star( delta_den[0], delta_den[1] );
	num_llr_u[p] = max_star( delta_num[0], delta_num[1] );

}

void pSW_sisoDecoder::compute_output(int k,int p)
{
	if (k < frame_size)
	{
		if (DecoderType == 5) // Scaling max-logMAP
		{
			output_u[k] = 0.75*(num_llr_u[p] - den_llr_u[p] - input_u[k]);
		}
		else
		{
			output_u[k] = num_llr_u[p] - den_llr_u[p] - input_u[k];
		}
	}

	for (int i=0;i<nn;i++)
		output_c[nn*k+i] = num_llr_c[p][i] - den_llr_c[p][i];	
}

void pSW_sisoDecoder::compute_block_beta(int k,int p,int s)
{
	/* precompute all possible branch metrics */
	update_branch_metric(k,p);

	/* update betas */
	update_block_beta(k,p,s);

	/* normalize beta */
	normalize_beta(p,s);
}

void pSW_sisoDecoder::update_beta_at_the_tail()
{
	for (int state = 0; state < max_states; state++)
	{
		beta[0][mm*max_states+state] = state == 0 ? 0 : -MAXLOG;
	}

	for (int k = frame_size + mm - 1; k >= frame_size; k--)
	{
		int s = k - frame_size;
		compute_block_beta(k,0,s);
	}

	int alpha_offset = num_subblocks*max_states;
	int offset = alpha_offset + (num_subblocks * num_windows - 1)*max_states;

	// save last beta
	for (int state=0; state < max_states; state++ )
	{
		alpha_beta_prev[offset + state] = beta[0][state];
	}
}

void pSW_sisoDecoder::update_alpha_beta_prev_for_next_iteration(int window_id)
{
	int p, offset, state;

	int alpha_offset = num_subblocks*max_states;
	
	for(p = 0; p < num_subblocks; p++)
	{
		if(window_id == num_windows - 1 && p < num_subblocks -1) // last window in a parallel processor (but not the last processor)
		{
			offset = (p+1)*max_states;

			// save alpha
			for (state = 0; state < max_states; state++)
			{
				alpha_beta_prev[offset+state] = alpha_prime[p][state];
			}
		}

		if(p > 0 || window_id > 0) // not the first window
		{
			offset = alpha_offset + (p * num_windows + window_id - 1)*max_states;

			// save beta
			for (state = 0; state < max_states; state++ )
			{
				alpha_beta_prev[offset + state] = beta[p][state];
			}
		}
	}

}

void pSW_sisoDecoder::compute_beta(int window_id)
{
	int s, k, p;

	int end = subblock_size;

	if (window_id == num_windows - 1)
	{
		end = last_window_size;
	}

	for(p = 0; p < num_subblocks; p++)
	{
		for (s = end - 1; s >= 0; s--)
		{
			k = p * sub_frame_size + window_id * subblock_size + s;
			compute_block_beta(k,p,s);
		}
	}
}

void pSW_sisoDecoder::compute_alpha_and_llr(int window_id)
{
	int s, k, p;
	int state;
	int end = subblock_size;

	if (window_id == num_windows - 1)
	{
		end = last_window_size;
	}

	for(p = 0; p < num_subblocks; p++)
	{
		for (s = 0; s < end; s++)
		{
			k = p * sub_frame_size + window_id * subblock_size + s;

			/* precompute all possible branch metrics */
			update_branch_metric(k,p);

			compute_block_alpha(k,p);

			compute_llr(k,p,s);

			/* normalize and shift */
			update_alpha_prime(p);

			compute_output(k,p);
		}
	}
}

void pSW_sisoDecoder::initialize_alpha_at_iteration_0()
{
	for (int p = 0; p < num_subblocks; p++)
	{
		int offset = p * max_states;

		for (int state = 0; state < max_states; state++)
		{
			if (offset == 0) // Start of the trellis diagram
			{
				alpha_beta_prev[offset + state] = state == 0 ? 0 : -MAXLOG;
			}
			else
			{
				alpha_beta_prev[offset + state] = 0;
			}
		}
	}
}

void pSW_sisoDecoder::initialize_alpha()
{
	for (int p = 0; p < num_subblocks; p++)
	{
		int offset = p * max_states;

		for (int state = 0; state < max_states; state++)
		{
			alpha_prime[p][state] = alpha_beta_prev[offset + state];
		}
	}
}

void pSW_sisoDecoder::initialize_beta_at_iteration_0
(
)
{
	int alpha_offset = num_subblocks*max_states;
	int offset;

	for (int p = 0; p < num_subblocks; p++)
	{
		for (int window_id = 0; window_id < num_windows; window_id++)
		{
			offset = alpha_offset + (window_id + p * num_windows) * max_states;

			for (int state = 0; state < max_states; state++)
			{
				if (p == num_subblocks && window_id == num_windows - 1) // the end of the trellis diagram
				{
					// Initialize end beta
					alpha_beta_prev[offset + state] = (state == 0 ? 0 : -MAXLOG);
				}
				else
				{
					alpha_beta_prev[offset + state] = 0;
				}
			}
		}
	}
}

/* initialize beta */
void pSW_sisoDecoder::initialize_beta
(
	int window_id
)
{
	int alpha_offset = num_subblocks*max_states;
	int offset;

	int k, end;

	for (int p = 0; p < num_subblocks; p++)
	{
		offset = alpha_offset + (window_id + p * num_windows) * max_states;

		// the block size may be less than subblock_size for the last window
		if(window_id == num_windows - 1) 
		{
			end = last_window_size;
		}
		else
		{
			end = subblock_size;
		}

		for (int state = 0; state < max_states; state++)
		{
			beta[p][end*max_states + state] = alpha_beta_prev[offset + state];
		}
	}
}

void pSW_sisoDecoder::do_window(int window_id)
{
	/* Initalize alpha only at teh first window */
	if (window_id == 0)
	{
		initialize_alpha();
	}

	initialize_beta(window_id);

	compute_beta(window_id);
	compute_alpha_and_llr(window_id);

	update_alpha_beta_prev_for_next_iteration(window_id);
}

void pSW_sisoDecoder::do_work()
{
	if(iteration <= 1)
	{
		/* Initalization */
		initialize_alpha_at_iteration_0();
		initialize_beta_at_iteration_0();
		update_beta_at_the_tail();
	}
	
	for (int i = 0; i < num_windows; i++)
	{
		do_window(i);
	}


	// Update outputs for passing alpha and beta to next iteration
	for(int w = 0; w < (1 + num_windows) * num_subblocks; w++)
	{
		int offset = w*max_states;

		for (int state = 0; state < max_states; state++)
		{
			output_b[offset+state] = alpha_beta_prev[offset+state];
		}
	}
}

