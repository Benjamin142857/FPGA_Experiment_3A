/////////////////////////////////////////////////////////////////////////////////////////
//
// file name      	: $Workfile:   Sfir8tap.CPP  $
// company name   	: altera corp.
// company address	: 101 innovation drive
//                 	  san jose, california 95134
//                 	  u.s.a.
//
// Copyright Altera Corp. 2000
//                 
//
/////////////////////////////////////////////////////////////////////////////////////////

#include <string.h>
#include <stdlib.h>

class Sfir8tap {

	double shiftdelay[1000];	
	int depth;
    int coefCount;
    int latency;
	double coef[7];
	
	int seqena;

	double accumulator;
	double result;
	
	void ResetTdl()
	{
    	for (int i =0;i<depth;i++)	shiftdelay[i] = 0.0;
	}

	int NextEnable(int ena, int sclr)
	{
		int bval;
		if (sclr>0) 	
		{
			bval = 0;
		}		
		else 
		{
			bval = 1;		
		}		
		return bval;
	}

public:

	Sfir8tap(double c0, double c1, double c2, double c3, double c4, double c5, double c6, double c7)
	{
        coefCount = 8;      // 8-tap filter
        latency = 3;        // extra latency introduced to match against hardware
        // note this latency is actually 1 less than the real latency as we
        // get 1 delay for free from reading in MdlUpdate and writing in MdlOutputs
		depth = coefCount + latency;
		ResetTdl();

		coef[0] = c0;
		coef[1] = c1;
		coef[2] = c2;
		coef[3] = c3;
		coef[4] = c4;
		coef[5] = c5;
		coef[6] = c6;
		coef[7] = c7;

		seqena = 1;
		accumulator = 0.0;
		result = 0.0;
	}

	void NextClock(double data, double ena, double sclr)
	{
		const int nce = (static_cast<int>(ena)) & 1;
		const int ncl = (static_cast<int>(sclr)) & 1;

		accumulator = 0.0;
		if (ncl>0)		
		{
			ResetTdl();
			seqena = 0;			
		}									
		else if ((nce>0) && (seqena>0))
		{
			for (int i=depth-1;i>0;i--)
			{
				shiftdelay[i] = shiftdelay[i-1];
			}
			shiftdelay[0] = data;
		}

		for (int i=0; i<=coefCount; i++)
		{
			accumulator = accumulator + shiftdelay[i + latency]*coef[i];
		}

		result = accumulator;
		seqena 	= NextEnable(nce, ncl);

	}
	double GetResult(void)	{return result;}; 
};

#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
#endif       // defined within this scope                     

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  Sfir8tap

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include "simstruc.h"

/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    /* See sfuntmpl.doc for more details on the macros below */
    ssSetNumSFcnParams(S, 9);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }
   	// Set DialogParameters not tunable
	const int iMaxssGetSFcnParamsCount = ssGetSFcnParamsCount(S);
	for (int p=0;p<iMaxssGetSFcnParamsCount;p++)	{ssSetSFcnParamTunable(S, p,  0);}     

    if (!ssSetNumInputPorts(S, 1)) return;
	ssSetInputPortWidth(S, 0, 1);
	ssSetInputPortDataType(S,  0, SS_DOUBLE);


	if (!ssSetNumOutputPorts(S, 1)) return;
	ssSetOutputPortWidth(S, 0, 1);
	ssSetOutputPortDataType(S, 0, SS_DOUBLE);


    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumDWork(S, DYNAMICALLY_SIZED); // reserve element in the pointers vector
    ssSetNumModes(S, 0); // to store a C++ object
    ssSetNumNonsampledZCs(S, 0);
    ssSetOptions(S, 0);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    const real_T  *psTime  = (const real_T *)mxGetData(ssGetSFcnParam(S,0));	
    if ((*psTime)<0.0)		ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    else					ssSetSampleTime(S, 0, (*psTime));	
    ssSetOffsetTime(S, 0, 0);
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
static void mdlStart(SimStruct *S)
{
	//parameter retrieval 

	const real_T *pcoef0	=  (const real_T *)mxGetData(ssGetSFcnParam(S,1));
	const real_T *pcoef1	=  (const real_T *)mxGetData(ssGetSFcnParam(S,2));
	const real_T *pcoef2	=  (const real_T *)mxGetData(ssGetSFcnParam(S,3));
	const real_T *pcoef3	=  (const real_T *)mxGetData(ssGetSFcnParam(S,4));
	const real_T *pcoef4	=  (const real_T *)mxGetData(ssGetSFcnParam(S,5));
	const real_T *pcoef5	=  (const real_T *)mxGetData(ssGetSFcnParam(S,6));
	const real_T *pcoef6	=  (const real_T *)mxGetData(ssGetSFcnParam(S,7));
	const real_T *pcoef7	=  (const real_T *)mxGetData(ssGetSFcnParam(S,8));

	const double ncoef0		=  (static_cast<double>(*pcoef0));
	const double ncoef1		=  (static_cast<double>(*pcoef1));
    const double ncoef2		=  (static_cast<double>(*pcoef2));
	const double ncoef3		=  (static_cast<double>(*pcoef3));
	const double ncoef4		=  (static_cast<double>(*pcoef4));
	const double ncoef5		=  (static_cast<double>(*pcoef5));
	const double ncoef6		=  (static_cast<double>(*pcoef6));
	const double ncoef7		=  (static_cast<double>(*pcoef7));

	ssGetDWork(S,0)		= (void *) new Sfir8tap(ncoef0,ncoef1,ncoef2,ncoef3,ncoef4,ncoef5,ncoef6,ncoef7);

}
#endif /*  MDL_START */

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    // retrieve C++ object from the pointers vector and use object
    Sfir8tap *pDelay = (Sfir8tap *) ssGetDWork(S,0);
	// Output Signals
	real_T  *y = ssGetOutputPortRealSignal(S,0);
    y[0] = pDelay->GetResult();
}



#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    Sfir8tap *pDelay = (Sfir8tap *) ssGetDWork(S,0);
	double d(0.0),ce(0.0), cl(0.0);
	const int nInputPorts = ssGetNumInputPorts(S);

	// Input signals
	InputRealPtrsType dPtrs 	= ssGetInputPortRealSignalPtrs(S,0);
    d 	= *dPtrs[0];  

	ce 	= 1.0; 
    cl 	= 0.0;  

    pDelay->NextClock(d, ce, cl);
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
    Sfir8tap *pDelay = (Sfir8tap*) ssGetDWork(S,0); // retrieve and destroy C++
    delete pDelay;                               // object in the termination
}                                                // function
/*======================================================*
 * See sfuntmpl.doc for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

#ifdef __cplusplus
} // end of extern "C" scope
#endif

