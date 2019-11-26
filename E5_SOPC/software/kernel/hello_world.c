/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */
#include "system.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include <stdio.h>

int main()
{
  // printf("Hello from Nios II!\n");
  while (1) {
	  if(IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE)==1)
		  IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, 1);
	  else
		  IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, 0);

  }
  return 0;
}
