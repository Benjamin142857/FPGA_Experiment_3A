

function [output out1 out2 lastfifosize fifomax] = umts_interleaver (LL,P)


pTable = [	 7,	 11,  13,  17,  19,  23,  29,  31,  37,  41, ...
			43,  47,  53,  59,  61,  67,  71,  73,  79,  83, ...
			89,	 97, 101, 103, 107, 109, 113, 127, 131, 137, ...
		   139, 149, 151, 157, 163, 167, 173, 179, 181, 191, ...
		   193, 197, 199, 211, 223, 227, 229, 233, 239, 241, ...
					   251, 257 ];
vTable = [	3,	2,	2,	3,	2,	5,	2,	3,	2,	6,	3, ...
			5,	2,	2,	2,	2,	7,	5,	3,	2,	3,	5, ...
			2,	5,	2,	6,	3,	3,	2,	3,	2,	2,	6, ...
			5,	2,	5,	2,	2,	2,	19,	5,	2,	3,	2, ...
			3,	2,	6,	3,	7,	7,	6,	3 ];

T5 =	[	4,	3,	2,	1,	0   ];
	
T10 =	[	9,	8,	7,	6,	5,	4,	3,	2,	1,	0 ];

T20a =	[	19,	9,	14,	4,	0,	2,	5,	7,	12,	18, ...
			16,	13,	17,	15,	3,	1,	6,	11,	8,	10 ];
	
T20b =	[	19,	9,	14,	4,	0,	2,	5,	7,	12,	18, ...
			10,	8,	13,	17,	3,	1,	16,	6,	15,	11 ];
						
input = [0:LL-1];

LL_RR_5 = 0;
LL_RR_10a = 0;
LL_RR_10b = 0;
LL_RR_20a = 0;
LL_RR_20b = 0;

%%	Step (1): Determine number of rows
	if ( ( 40<=LL )&&( LL <= 159 ) )
		RR = 5;
		LL_RR_5 = 1;
	elseif ( ( 160<=LL )&&( LL <= 200 ) )
		RR = 10;
		LL_RR_10a = 1;
	elseif ( ( 481<=LL )&&( LL <= 530 ) )
		RR = 10;
		LL_RR_10b = 1;
	elseif ( ( 2281<=LL )&&( LL<=2480) )||( ( 3161<=LL )&&( LL<=3210 ) )
		RR = 20;
		LL_RR_20a = 1;
	else
		RR = 20;
		LL_RR_20b = 1;
	end;

%%	Step (2): Determine the prime number for intra-permutation
%%            and the number of columns */
	if ( LL_RR_10b == 1 ) %( 481<=LL )&&( LL <= 530 ) ) 
		pValue = 53;
		CC = pValue;
		vValue = 2;
	else
		for index=1:52
			if ( LL <= RR*(pTable(index) + 1)  )
				break;
			end
		end
		pValue = pTable(index);
		vValue = vTable(index);
		if ( LL <=RR*(pValue-1) ) 
			CC = pValue - 1;
		elseif ( RR*pValue < LL )
			CC = pValue + 1;
		else
			CC = pValue;
		end
	end

%%	Step (3): Stuff the bits into a rectangular matrix */
	index = 1;
	for i=1:RR
		for j=1:CC
			if ( index <= LL )
				Matrix(i,j) = input(index);
			else
%%				Insert Dummy Bits 
				Matrix(i,j) = -1;
			end
			index = index + 1;
		end
	end

%%	Step (4): Construct base sequence for intra-row permutations
	s(1) = 1;
	
	for j=2:pValue-1
		s(j) = mod((vValue*s(j-1)),pValue);
%%      printf( "s[%d] = %d\n", j, s[j] );
	end

%%	Step (5): Construct q-sequence --- this is a little confusing
	q(1) = 1;
	for i=2:RR
		for index=1:52
			if ( ( gcd( pTable(index), pValue-1 ) == 1 )&&( pTable(index) > q(i-1) ) )
				q(i) = pTable(index);
				break;
			end
		end
	end

%%	Step (6): Permute the q-sequence to make the r-sequence
	if ( RR == 5 )
		for i=1:RR
			r( T5(i)+1 ) = q(i);            
		end
	elseif (RR == 10)
		for i=1:RR
			r( T10(i)+1 ) = q(i);
		end
	elseif ( LL_RR_20a == 1 ) %( ( 2281<=LL )&&( LL<=2480) )||( ( 3161<=LL )&&( LL<=3210 ) ) )
		for i=1:RR
			r( T20a(i)+1 ) = q(i);
		end
	else 
		for i=1:RR
			r( T20b(i)+1 ) = q(i);
		end
	end
    

%%	Step (7): Perform intra-row permutations
	for i=0:RR-1 
		if ( CC == pValue )
			for j=0:pValue-2
				index = s( mod((j*r(i+1)), (pValue-1)) +1 );
				IntraMatrix(i+1, j+1) = Matrix(i+1, index+1);
			end
			IntraMatrix( i+1, pValue ) = Matrix( i+1, 1 );
		elseif ( CC == pValue + 1 )
			for j=0:pValue-2
				index = s( mod((j*r(i+1)),(pValue-1))+1);
				IntraMatrix( i+1, j+1 ) = Matrix( i+1, index+1 );
			end
			IntraMatrix(i+1, pValue) = Matrix( i+1, 1 );
			IntraMatrix(i+1, pValue+1) = Matrix( i+1, pValue+1 );

			if ( ( LL == RR*CC )&&(i==RR-1) )
				%% Just exchange bits in the last row 
				itemp = IntraMatrix(RR,1);
				IntraMatrix(RR,1) = IntraMatrix(RR,pValue+1);
				IntraMatrix(RR, pValue+1)=itemp;
			end
		else
			for j=0:pValue-2
				index = s( mod((j*r(i+1)),(pValue-1)) + 1 ) -1;
				IntraMatrix(i+1, j+1) = Matrix(i+1, index+1);
			end
		end
%%		/* for (j=0;j<CC;j++)
%%			printf( "%d ", IntraMatrix( i + j*RR ) );
%%		printf( "\n" ); */
	end

%%	Step (8): Perform inter-row permutations
	for i=1:RR
		if ( RR == 5 )
			index = T5(i);
		elseif (RR == 10)
			index = T10(i);
		elseif ( LL_RR_20a == 1 ) %( ( 2281<=LL )&&( LL<=2480) )||( ( 3161<=LL )&&( LL<=3210 ) ) )
			index = T20a(i);
		else
			index = T20b(i);
		end

		for j=1:CC
			InterMatrix(i, j) = IntraMatrix(index+1, j);
		end
	end

%%	Step (9): Read the bits back out from the matrix
	index = 1;
    pw_size = ceil((LL)/P);
	for j=1:CC
		for i=1:RR
			if ( InterMatrix(i,j) >= 0 )
				output(index) = InterMatrix(i, j);
                %% calculate paralling ram addresses
                out1(index) = floor(output(index) / pw_size);
                out2(index) = mod(output(index), pw_size);
				index = index + 1;
			end
		end
    end

 %% Calculate conflicts
 FIFO = zeros(1,P);
 fifomax = 0;
 num_conflicts = 0;
 for i = 1:pw_size
     for j = 1:P
       index = i + (j-1)*pw_size;
       if(index <= LL)
         tempM(j) = out1(index);
         FIFO(out1(index)+1) = FIFO(out1(index)+1) + 1;
         tM(i,j) = tempM(j);
       end
     end
     if (max(FIFO) > fifomax)
         fifomax = max(FIFO);
     end
     for j = 1:P
         if  FIFO(j) > 0
              FIFO(j) =  FIFO(j)-1;
         end
     end
     
     if (length(tempM) ~= length(unique(tempM)))
         num_conflicts = num_conflicts +1;
     end
 end
 
 lastfifosize = max(FIFO);
 
%fprintf ('pw_size = %d, num_conflicts = %d fifo-length=%d fifo-max=%d\n', pw_size, num_conflicts, lastfifosize, fifomax);