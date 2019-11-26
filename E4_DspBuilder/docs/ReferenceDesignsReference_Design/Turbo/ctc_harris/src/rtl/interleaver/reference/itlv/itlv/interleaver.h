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

   if (block < 187)
	   n = 3;
   else if (block < 403)
	   n = 4;
   else if (block < 787)
	   n = 5;
   else if (block < 1555)
	   n = 6;
   else if (block < 3090)
	   n = 7;
   else 
	   n = 8;
   


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
       n_plus_5_counter++;
       if (new_index >= block)
          continue;
       turbo_intlv[i]              = new_index;
//       turbo_deintlv[new_index]    = i;
       index_flag[new_index] = 1;
       i++;
       }

   printf("Done Intlv %d\n", block);
}
