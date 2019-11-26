#include <stdio.h>
#include <stdarg.h>
#include <io.h>
#include "system.h"


#define c1_offset 0
#define c2_offset 1
#define c3_offset 2
#define c4_offset 3




int main()   // Load and read back filter coefficients two times
{ 
   alt_8  readback1, readback2, readback3, readback4;


// 1. Define Coefficient Values:
   alt_u8  c1_value  =  1;
   alt_u8  c2_value  =  0;
   alt_u8  c3_value  =  0;
   alt_u8  c4_value  =  0; 

   printf("LOADING...\n\n");
   
// Load Coefficients:
   IOWR_8DIRECT(MY_TOPAVALON_AVALON_MM_WRITE_SLAVE_BASE, c1_offset, c1_value);
   IOWR_8DIRECT(MY_TOPAVALON_AVALON_MM_WRITE_SLAVE_BASE, c2_offset, c2_value);
   IOWR_8DIRECT(MY_TOPAVALON_AVALON_MM_WRITE_SLAVE_BASE, c3_offset, c3_value);
   IOWR_8DIRECT(MY_TOPAVALON_AVALON_MM_WRITE_SLAVE_BASE, c4_offset, c4_value);

// Read Back Coefficients:
   readback1 = IORD_8DIRECT(MY_TOPAVALON_AVALON_MM_READ_SLAVE_BASE, c1_offset);
   readback2 = IORD_8DIRECT(MY_TOPAVALON_AVALON_MM_READ_SLAVE_BASE, c2_offset);
   readback3 = IORD_8DIRECT(MY_TOPAVALON_AVALON_MM_READ_SLAVE_BASE, c3_offset);
   readback4 = IORD_8DIRECT(MY_TOPAVALON_AVALON_MM_READ_SLAVE_BASE, c4_offset);
   printf("Coeffecient 1 = %d\n", readback1);
   printf("Coeffecient 2 = %d\n", readback2);
   printf("Coeffecient 3 = %d\n", readback3);
   printf("Coeffecient 4 = %d\n", readback4);
  
   printf("\nRELOADING...\n\n");
 
// 2. Re-Define Coefficient Values:
   c1_value  =  0;
   c2_value  =  0;
   c3_value  =  1;
   c4_value  =  0; 
    
// Re-Load Coefficients:
   IOWR_8DIRECT(MY_TOPAVALON_AVALON_MM_WRITE_SLAVE_BASE, c1_offset, c1_value);
   IOWR_8DIRECT(MY_TOPAVALON_AVALON_MM_WRITE_SLAVE_BASE, c2_offset, c2_value);
   IOWR_8DIRECT(MY_TOPAVALON_AVALON_MM_WRITE_SLAVE_BASE, c3_offset, c3_value);
   IOWR_8DIRECT(MY_TOPAVALON_AVALON_MM_WRITE_SLAVE_BASE, c4_offset, c4_value);

// Re-Read Back Coefficients:
   readback1 = IORD_8DIRECT(MY_TOPAVALON_AVALON_MM_READ_SLAVE_BASE, c1_offset);
   readback2 = IORD_8DIRECT(MY_TOPAVALON_AVALON_MM_READ_SLAVE_BASE, c2_offset);
   readback3 = IORD_8DIRECT(MY_TOPAVALON_AVALON_MM_READ_SLAVE_BASE, c3_offset);
   readback4 = IORD_8DIRECT(MY_TOPAVALON_AVALON_MM_READ_SLAVE_BASE, c4_offset);
   printf("Coeffecient 1 = %d\n", readback1);
   printf("Coeffecient 2 = %d\n", readback2);
   printf("Coeffecient 3 = %d\n", readback3);
   printf("Coeffecient 4 = %d\n", readback4);
   

  return 0;
  
}
