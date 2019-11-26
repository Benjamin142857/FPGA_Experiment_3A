/* File interleaver.h
   
   Description: Functions used to create the UMTS/3GPP and CCSDS interleavers.

   Copyright (C) 2005-2006, Matthew C. Valenti

   Last updated on June 24, 2006

   Functions  gcd and CreateUmtsInterleaver are part of the Iterative Solutions 
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

/* Function gcd()

  Copyright 2001, Matthew C. Valenti.
	
  Description: Finds the greatest common divisor of the two integer-valued inputs.

	Input parameters:
		m		Input argument one (an integer).
		n		Input argument two (also an integer).

	Output parameters:
		out[]	The greatest common divisor of m and n.
	
  This function is used by UmtsTurboEncode()   */

int gcd( int m, int n )
{
    /*  The following is no longer needed 7/29/01 MCV
    int Rn;

    do {
        Rn = a % b;
        a = b;
        b = Rn;
    }while(Rn != 0);

    return a; */

	/* Note: For the UMTS interleaver, the first of these two
	values is prime.  Therefore we just have to check to see if the
	first number divides into the second one */

	if ( n%m == 0 ) {
		/* printf( "%d",m ); */
		return m;
	} else {
		/* printf( "x" ); */
		return 1;
	}
}


/* Function CreateCcsdsInterleaver()

  Copyright 2006, Matthew C. Valenti.
	
  Description: Creates the CCSDS interleaver.

	Input parameters:
		input		The input data frame of length LL bits.
					Ideally, this should be a vector containing the integers
					0 to L-1 in ascending order.
		LL			The number of data bits in the input frame.

	Output parameters:
		output[]	The interleaved output.
	
*/

void CreateCcsdsInterleaver( 
		int LL,
		int *output )

{
	int m, index, k1, k1by2, k2, i, j, t, q, c;
	int pTable[8] = { 31, 37, 43, 47, 53, 59, 61, 67 };

	/* deteremine parameter values */
	k1 = 8;
	k1by2 = 4;
	if ( ( LL == 1784 )||( LL == 3568 )||( LL == 7136 )||( LL == 8920 ) ) {
		k2 = (int) (LL/k1);
	} else {
		printf( "Error: CCSDS Interleaver size must be 7184, 3568, 7136, or 8920" );
		return;
	}

	/* determine interleaving pattern */
	for (index=0;index<LL;index++) {
		m = index%2;
		i = (int) (index/(2*k2));
		j = ( (int) (index/2) ) - i*k2;
		t = ( 19*i + 1 )%(k1by2);
		q = t%8;
		c = (pTable[q]*j+21*m)%k2;
		output[index] = 2*(t+c*k1by2+1)-m-1;
		/* printf( "%d %d %d %d %d %d %d\n", m, i, j, t, q, c, output[index] ); */
	}

	
}


/* Function CreateUmtsInterleaver()

  Copyright 2001-2006, Matthew C. Valenti.
	
  Description: Creates the UMTS interleaver.

	Input parameters:
		input		The input data frame of length LL bits.
					Ideally, this should be a vector containing the integers
					0 to L-1 in ascending order.
		LL			The number of data bits in the input frame.

	Output parameters:
		output[]	The interleaved output.
	
*/

void CreateUmtsInterleaver( 
		int LL,
		int *input,
		int *output )
{
	int RR, CC;
	int index, i, j, itemp;
	int pValue, vValue;
	int pTable[52] = {	7,	11,	13,	17,	19,	23,	29,	31,	37,	41,	43,
						47,	53,	59,	61,	67,	71,	73,	79,	83,	89,	97,
						101,103,107,109,113,127,131,137,139,149,151,
						157,163,167,173,179,181,191,193,197,199,211,
						223,227,229,233,239,241,251,257 };
	int vTable[52] = {	3,	2,	2,	3,	2,	5,	2,	3,	2,	6,	3,
						5,	2,	2,	2,	2,	7,	5,	3,	2,	3,	5,
						2,	5,	2,	6,	3,	3,	2,	3,	2,	2,	6,
						5,	2,	5,	2,	2,	2,	19,	5,	2,	3,	2,
						3,	2,	6,	3,	7,	7,	6,	3 };
	int T5[5] =		{	4,	3,	2,	1,	0	};
	int T10[10] =	{	9,	8,	7,	6,	5,	4,	3,	2,	1,	0 };
	int T20a[20] =	{	19,	9,	14,	4,	0,	2,	5,	7,	12,	18,
						16,	13,	17,	15,	3,	1,	6,	11,	8,	10 };
	int T20b[20] =	{	19,	9,	14,	4,	0,	2,	5,	7,	12,	18,
						10,	8,	13,	17,	3,	1,	16,	6,	15,	11 };
	
	int *Matrix, *IntraMatrix, *InterMatrix, *s, *q, *r;

	/* Step (1): Determine number of rows */
	if ( ( 40<=LL )&&( LL <= 159 ) ) {
		RR = 5;
	} else if ( ( 160<=LL )&&( LL <= 200 ) ) {
		RR = 10;
	} else if ( ( 481<=LL )&&( LL <= 530 ) ) {
		RR = 10;
	} else {
		RR = 20;
	}

	/* Step (2): Determine the prime number for intra-permutation 
			     and the number of columns */
	if ( ( 481<=LL )&&( LL <= 530 ) ) {
		pValue = 53;
		CC = pValue;
		vValue = 2;
	} else {
		for (index=0;index<52;index++) {
			if ( LL <= RR*(pTable[index] + 1)  ) {
				break;
			}
		}
		pValue = pTable[index];
		vValue = vTable[index];
		if ( LL <=RR*(pValue-1) ) {
			CC = pValue - 1;
		} else if ( RR*pValue < LL ) {
			CC = pValue + 1;
		} else {
			CC = pValue;
		}
	}

	/* Step (3): Stuff the bits into a rectangular matrix */
	Matrix = calloc( RR*CC, sizeof( int ) );
	InterMatrix = calloc( RR*CC, sizeof( int ) );
	IntraMatrix = calloc( RR*CC, sizeof( int ) );

	index = 0;
	for( i=0; i<RR; i++ ) {
		for ( j=0;j<CC;j++ ) {
			if ( index < LL ) {
				Matrix[i+j*RR] = input[index];
			} else {
				/* Insert Dummy Bits */
				Matrix[i+j*RR] = -1;
			}
			index++;
		}
	}

	/* Step (4): Construct base sequence for intra-row permutations */
	s = calloc( pValue-1, sizeof( int) );
	s[0] = 1;
	
	for (j=1;j<pValue-1;j++) {
		s[j] = (vValue*s[j-1])%pValue;
        /* printf( "s[%d] = %d\n", j, s[j] ); */
	}

	/* Step (5): Construct q-sequence --- this is a little confusing */
	q = calloc( RR, sizeof( int ) );
	q[0] = 1;

	index = 0;
	for (i=1;i<RR;i++) {
		itemp = index;
		for (index=itemp;index<52;index++ ) {
			if ( ( gcd( pTable[index], pValue-1 ) == 1 )&&( pTable[index] > q[i-1] ) ) {
				q[i] = pTable[index];
				break;
			}
		}
	}

	/* Step (6): Permute the q-sequence to make the r-sequence */
	r = calloc( RR, sizeof( int ) );
	if ( RR == 5 ) {
		for (i=0;i<RR;i++) {
			r[ T5[i] ] = q[i];            
		}
	} else if (RR == 10) {
		for (i=0;i<RR;i++) {
			r[ T10[i] ] = q[i];
		}
	} else if ( ( ( 2281<=LL )&&( LL<=2480) )||( ( 3161<=LL )&&( LL<=3210 ) ) ) {
		for (i=0;i<RR;i++) {
			r[ T20a[i] ] = q[i];
		}
	} else {
		for (i=0;i<RR;i++) {
			r[ T20b[i] ] = q[i];
		}
	}
    
    /* for (i=0;i<RR;i++)
        printf( "r[%d] = %d\n", i, r[i] );    */

	/* Step (7): Perform intra-row permutations */
	for (i=0;i<RR;i++) {
		if ( CC == pValue ) {
			for (j=0;j<=pValue-2;j++) {
				index = s[ (j*r[i])%(pValue-1) ];
				IntraMatrix[ i+j*RR ] = Matrix[ i+index*RR ];
			}
			IntraMatrix[ i + (pValue-1)*RR ] = Matrix[ i ];
		} else if ( CC == pValue + 1 ) {
			for (j=0;j<=pValue-2;j++) {
				index = s[ (j*r[i])%(pValue-1) ];
				IntraMatrix[ i+j*RR ] = Matrix[ i+index*RR ];
			}
			IntraMatrix[ i + (pValue-1)*RR ] = Matrix[ i ];
			IntraMatrix[ i + pValue*RR ] = Matrix[ i + pValue*RR ];
			/* Exchange  */
			if ( ( LL == RR*CC )&&(i==RR-1) ) {
				/* Just exchange bits in the last row */
				itemp = IntraMatrix[RR-1];
				IntraMatrix[RR-1] = IntraMatrix[(RR-1)+RR*pValue];
				IntraMatrix[(RR-1)+RR*pValue]=itemp;
			}
		} else {
			for (j=0;j<=pValue-2;j++) {
				index = s[ (j*r[i])%(pValue-1) ] - 1;
				IntraMatrix[ i+j*RR ] = Matrix[ i+index*RR ];
			}
		}
	}

	/* Step (8): Perform inter-row permutations */
	for (i=0;i<RR;i++) {
		if ( RR == 5 ) {
			index = T5[i];
		} else if (RR == 10) {
			index = T10[i];
		} else if ( ( ( 2281<=LL )&&( LL<=2480) )||( ( 3161<=LL )&&( LL<=3210 ) ) ) {
			index = T20a[i];
		} else {
			index = T20b[i];
		}

		for (j=0;j<CC;j++) {
			InterMatrix[ i+j*RR ] = IntraMatrix[ index+j*RR];
		}
	}

	/* Step (9): Read the bits back out from the matrix */
	index = 0;
	for( j=0; j<CC; j++ ) {
		for ( i=0;i<RR;i++ ) {
			if ( InterMatrix[i+j*RR] >= 0 ) {
				output[index] = InterMatrix[i+j*RR];
				index++;
			}
		}
	}

	free( Matrix );
	free( InterMatrix );
	free( IntraMatrix );
	free( s );
	free( q );
	free( r );

}

static unsigned short BitReverse(unsigned short val, unsigned short bits)
{unsigned short i,mask=1<<(bits-1),new_mask=1,new_val=0;

   for (i=0; i<bits; i++,mask>>=1,new_mask<<=1) {
       if (mask&val)
          new_val |= new_mask;
       }

   return(new_val);
}


/* Function Create3GPP2Interleaver()

  Copyright 2010
	
  Description: Creates a 3GPP interleaver.

	Input parameters:
		input		The input data frame of length LL bits.
					Ideally, this should be a vector containing the integers
					0 to L-1 in ascending order.
		LL			The number of data bits in the input frame.

	Output parameters:
		output[]	The interleaved output.
	
*/

static void Create3GPP2Interleaver( 
		int LL,
		int *output )
{
short index_flag[5114];  // Max blk size: 5114
static const short intlv_look_up_table_multiplier[8][32] = 
{
  {   1,   1,   3,   5,   1,   5,   1,   5,   3,   5,   3,   5,   3,   5,   5,   1,
      3,   5,   3,   5,   3,   5,   5,   5,   1,   5,   1,   5,   3,   5,   5,   3  },
  {   5,  15,   5,  15,   1,   9,   9,  15,  13,  15,   7,  11,  15,   3,  15,   5, 
     13,  15,   9,   3,   1,   3,  15,   1,  13,   1,   9,  15,  11,   3,  15,   5  },
  {  27,   3,   1,  15,  13,  17,  23,  13,   9,   3,  15,   3,  13,   1,  13,  29, 
     21,  19,   1,   3,  29,  17,  25,  29,   9,  13,  23,  13,  13,   1,  13,  13  }, 
  {   3,  27,  15,  13,  29,   5,   1,  31,   3,   9,  15,  31,  17,   5,  39,   1, 
     19,  27,  15,  13,  45,   5,  33,  15,  13,   9,  15,  31,  17,   5,  15,  33  },
  {  15, 127,  89,   1,  31,  15,  61,  47, 127,  17, 119,  15,  57, 123,  95,   5, 
     85,  17,  55,  57,  15,  41,  93,  87,  63,  15,  13,  15,  81,  57,  31,  69  },
  {   3,   1,   5,  83,  19, 179,  19,  99,  23,   1,   3,  13,  13,   3,  17,   1,
     63, 131,  17, 131, 211, 173, 231, 171,  23, 147, 243, 213, 189,  51,  15,  67  },
  {  13, 335,  87,  15,  15,   1, 333,  11,  13,   1, 121, 155,   1, 175, 421,   5,
    509, 215,  47, 425, 295, 229, 427,  83, 409, 387, 193,  57, 501, 313, 489, 391  },
  {   1, 349, 303, 721, 973, 703, 761, 327, 453,  95, 241, 187, 497, 909, 769, 349,
     71, 557, 197, 499, 409, 259, 335, 253, 677, 717, 313, 757, 189,  15,  75, 163  }
};

   int* turbo_intlv = output;
   int block = LL;
   int i,n,n_plus_5_counter=0,n_lsb_mask,table_offset,mask_five_lsbs=(1<<5)-1;

   /* First determine interleaver parameter n */
   n = ((int)((log10(block)/log10(2.0))+0.99999)) - 5;

   /* Compute n_lsb_mask */
   n_lsb_mask = (1<<n)-1;

   /* Compute table offset for look-up table based on n */
   if (n <= 3)
      table_offset = 0;
   else
      table_offset = n - 3;

   /* Zero array to test interleaver later */
   for (i=0; i<block; i++)
       index_flag[i] = 0;

   /* Algorithm found in 3G specification */
   for (i=0; i<block; ) {
       long new_value=((n_plus_5_counter>>5)+1)&n_lsb_mask;
       long five_lsbs=n_plus_5_counter&mask_five_lsbs;
       long lut_multiply=intlv_look_up_table_multiplier[table_offset][five_lsbs];
       long bit_reversed_five_lsbs=BitReverse(five_lsbs, 5);
       long new_lsbs=(lut_multiply*new_value)&n_lsb_mask;
       long new_index=(bit_reversed_five_lsbs<<n)|new_lsbs;
       printf("new_value %4d  ", new_value);
       printf("five_lsbs %2d  ", five_lsbs);
       printf("lut_multiply %4d  ", lut_multiply);
       printf(" br_five_lsbs  %2d  ", bit_reversed_five_lsbs);
       printf("new_lsbs %4d  ", new_lsbs, i);
       printf("new_index %4d  \n", new_index);

       n_plus_5_counter++;
       if (new_index >= block) 
          continue;
	   
       turbo_intlv[i]              = new_index;
//       turbo_deintlv[new_index]    = i;
       index_flag[new_index] = 1;
       i++;
       }

   printf("Done Intlv %d\n", block);

   for (i=0; i<block; i++ ) {
       printf(" %d   ->   %d\n", turbo_intlv[i], i);
   }
}
