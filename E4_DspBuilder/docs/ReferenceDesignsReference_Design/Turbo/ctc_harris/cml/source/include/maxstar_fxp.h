/* File maxstar.h

   Description: Performs the max* operations (Jacobian logarithm) defined as:
		max*( x, y ) = max( x,y) + log( 1 + exp( - |x-y| ) )

   There are several versions of this function, max_starX, where "X":
      X = 0 For linear approximation to log-MAP
        = 1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y) )
        = 2 For Constant-log-MAP algorithm
	    = 3 For log-MAP, correction factor from small nonuniform table and interpolation
        = 4 For log-MAP, correction factor uses C function calls

   Calling syntax:
      output = max_starX( delta1, delta2 )

   Where:
  	  output =	The result of max*(x,y)

   	  delta1 = T] he first argument (i.e. x) of max*(x,y)
	  delta2 = The second argument (i.e. y) of max*(x,y)

   Copyright (C) 2005, Matthew C. Valenti

   Functions max_star0, max_star1, max_star2, max_star3, and max_star4
   are part of the Iterative Solutions Coded Modulation Library
   The Iterative Solutions Coded Modulation Library is free software;
   you can redistribute it and/or modify it under the terms of 
   the GNU Lesser General Public License as published by the 
   Free Software Foundation; either version 2.1 of the License, 
   or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
  
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#ifndef INC_MAXSTAR_H
#define INC_MAXSTAR_H

#include <math.h>

#if !defined(SC_INCLUDE_FX)
#define SC_INCLUDE_FX
#endif
#include "systemc.h"

/* values for the jacobian logarithm table (DecoderType=4) */
const sc_ufix_fast BOUNDARY0("0.0");
const sc_ufix_fast BOUNDARY1("0.4200");
const sc_ufix_fast BOUNDARY2("0.8500");
const sc_ufix_fast BOUNDARY3("1.3100");
const sc_ufix_fast BOUNDARY4("1.8300");
const sc_ufix_fast BOUNDARY5("2.4100");
const sc_ufix_fast BOUNDARY6("3.1300");
const sc_ufix_fast BOUNDARY7("4.0800");
const sc_ufix_fast BOUNDARY8("5.6000");

const soft_fix_type SLOPE0("-0.44788139700522");
const soft_fix_type SLOPE1("-0.34691145436176");
const soft_fix_type SLOPE2("-0.25432579542705");
const soft_fix_type SLOPE3("-0.17326680196715");
const soft_fix_type SLOPE4("-0.10822110027877");
const soft_fix_type SLOPE5("-0.06002650498009");
const soft_fix_type SLOPE6("-0.02739265095522");
const soft_fix_type SLOPE7("-0.00860202759280");

const sc_ufix_fast VALUE0("0.68954718055995");
const sc_ufix_fast VALUE1("0.50153699381775");
const sc_ufix_fast VALUE2("0.35256506844219");
const sc_ufix_fast VALUE3("0.23567520254575");
const sc_ufix_fast VALUE4("0.14607646552283");
const sc_ufix_fast VALUE5("0.08360822736113");
const sc_ufix_fast VALUE6("0.04088914377547");
const sc_ufix_fast VALUE7("0.01516612536801");

/* values for the constant log-MAP algorithm (DecoderType=3) */
const sc_ufix_fast CVALUE("0.5");
const sc_ufix_fast TVALUE("1.5");

/* values for the linear approximation (DecoderType=1) */
const soft_fix_type TTHRESH("2.508");
const soft_fix_type AVALUE ("-0.236");
const soft_fix_type BVALUE ("0.592");

/* Values for linear approximation (DecoderType=5) */
const soft_fix_type AJIAN("-0.24904163195436");
const soft_fix_type TJIAN("2.50681740420944");

/* The linear-log-MAP algorithm */
static soft_fix_type max_star0
(
	soft_fix_type delta1, 
	soft_fix_type delta2
)
{
	register soft_fix_type diff, result;
	
	diff = delta2 - delta1;

	if ( diff > TJIAN )
		result = delta2;
	else if ( diff < -TJIAN )
		result = delta1;
	else if ( diff > 0 )
		result = (delta2 + AJIAN*(diff-TJIAN));
	else
		result = (delta1 - AJIAN*(diff+TJIAN));

	return (result);
}


/* The max-log-MAP algorithm */
static soft_fix_type max_star1
(
	soft_fix_type delta1, 
	soft_fix_type delta2
)
{
	/* Return the maximum of delta1 and delta2 */
	if (delta1 > delta2)		
		return(delta1);
	else			
		return(delta2);
}


/* The constant-log-MAP algorithm */
static soft_fix_type max_star2
(
	soft_fix_type delta1, 
	soft_fix_type delta2
)
{
/* Return maximum of delta1 and delta2
   and in correction value if |delta1-delta2| < TVALUE */
	register soft_fix_type diff;	
	diff = delta2 - delta1;

	if ( diff > TVALUE )
		return( delta2 );
	else if ( diff < -TVALUE )
		return( delta1 );
	else if ( diff > 0 )
		return( delta2 + CVALUE );
	else
		return( delta1 + CVALUE );

}

/* Accurate approximation of the log-MAP algorithm using an optimized
   8 element nonuniform table with linear interpolation */
static soft_fix_type max_star3
(
	soft_fix_type delta1, 
	soft_fix_type delta2
)
{
	register soft_fix_type diff, result;
	diff = delta2 > delta1 ? (delta2 - delta1) : (delta1 - delta2);

	// LUT
	// diff    0  0.25 0.5 0.75 1.00 1.25 1.50 1.75 2.0  >2.0
	// max* 0.75  0.50 0.5 0.50 0.25 0.25 0.25 0.25 0.25  0

	if (diff == 0)
	{
		result = 0.75;
	}
	else if (diff <= 0.75)
	{
		result = 0.5;
	}
	else if (diff <= 2.0)
	{
		result = 0.25;
	}
	else
	{
		result = 0.0;
	}

	result += delta2 > delta1 ? delta2 : delta1;

	return (result);
	
/*
	if (delta1 > delta2) {
		if (diff > BOUNDARY8 )
			return( delta1 );
		else if ( diff > BOUNDARY4 ) {
			if (diff > BOUNDARY6 ) {
				if ( diff > BOUNDARY7 )
					return( delta1 + VALUE7 + SLOPE7*(diff-BOUNDARY7) );
				else
					return( delta1 + VALUE6 + SLOPE6*(diff-BOUNDARY6) );
			} else {
				if ( diff > BOUNDARY5 )
					return( delta1 + VALUE5 + SLOPE5*(diff-BOUNDARY5) );
				else
					return( delta1 + VALUE4 + SLOPE4*(diff-BOUNDARY4) );
			}	
		} else {
			if (diff > BOUNDARY2 ) {
				if ( diff > BOUNDARY3 )
					return( delta1 + VALUE3 + SLOPE3*(diff-BOUNDARY3) );
				else
					return( delta1 + VALUE2 + SLOPE2*(diff-BOUNDARY2) );
			} else {
				if ( diff > BOUNDARY1 )
					return( delta1 + VALUE1 + SLOPE1*(diff-BOUNDARY1) );
				else
					return( delta1 + VALUE0 + SLOPE0*(diff-BOUNDARY0) );
			}
		}
	} else {
		if (diff > BOUNDARY8 )
			return( delta2 );
		else if ( diff > BOUNDARY4 ) {
			if (diff > BOUNDARY6 ) {
				if ( diff > BOUNDARY7 )
					return( delta2 + VALUE7 + SLOPE7*(diff-BOUNDARY7) );
				else
					return( delta2 + VALUE6 + SLOPE6*(diff-BOUNDARY6) );
			} else {
				if ( diff > BOUNDARY5 )
					return( delta2 + VALUE5 + SLOPE5*(diff-BOUNDARY5) );
				else
					return( delta2 + VALUE4 + SLOPE4*(diff-BOUNDARY4) );
			}	
		} else {
			if (diff > BOUNDARY2 ) {
				if ( diff > BOUNDARY3 )
					return( delta2 + VALUE3 + SLOPE3*(diff-BOUNDARY3) );
				else
					return( delta2 + VALUE2 + SLOPE2*(diff-BOUNDARY2) );
			} else {
				if ( diff > BOUNDARY1 )
					return( delta2 + VALUE1 + SLOPE1*(diff-BOUNDARY1) );
				else
					return( delta2 + VALUE0 + SLOPE0*(diff-BOUNDARY0) );
			}
		}
	}
*/
}

/* Exact calculation of the log-MAP algorithm */
static float max_star4
(
	float delta1, 
	float delta2
)
{
	/* Use C-function calls to compute the correction function */	
	if (delta1 > delta2) {
		return( (float) (delta1 + log( 1 + exp( delta2-delta1) ) ) );		
	} else	{
		return( (float) (delta2 + log( 1 + exp( delta1-delta2) ) ) );		
	}
}

#endif /* INC_MAXSTAR_H */
