// itlv.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "interleaver.h"
#include <math.h>
#include <stdlib.h>

int _tmain(int argc, _TCHAR* argv[])
{
	int     DataLength;
   double  *output_p;
	int     *alpha_code; /* interleaver */
	int     i;


	/* initialize the input data */
	DataLength   = 40;


	/* Create the interleaver */
	alpha_code = calloc( DataLength, sizeof(int) );
	Create3GPP2Interleaver( DataLength, alpha_code );


	return 0;
}

