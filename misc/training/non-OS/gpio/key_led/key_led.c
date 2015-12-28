/* led */
#define GPMCON		(*(volatile unsigned long *)0x7F008820)
#define GPMDAT		(*(volatile unsigned long *)0x7F008824)

#define GPM0_OUT	(1<<(0*4))	/* 0000 0000 0000 0000 0000 0000 0000 0001 */  /* LED1 */
#define GPM1_OUT	(1<<(1*4))	/* 0000 0000 0000 0000 0000 0000 0001 0000 */  /* LED2 */
#define GPM2_OUT	(1<<(2*4))	/* 0000 0000 0000 0000 0000 0001 0000 0000 */  /* LED3 */
#define GPM3_OUT	(1<<(3*4))	/* 0000 0000 0000 0000 0001 0000 0000 0000 */  /* LED4 */
	

/* key */
#define GPNCON		(*(volatile unsigned long *)0X7F008830)
#define GPNDAT		(*(volatile unsigned long *)0X7F008834)
#define GPNPUD		/* has up */

#define GPN0_IN		(~0x000003)	/* xxxx xxxx xxxx xxxx xxxx 1111 1111 1100 */  /* S2 - KEYINT1 - GPN0 */
#define GPN1_IN		(~0x00000C)	/* xxxx xxxx xxxx xxxx xxxx 1111 1111 0011 */  /* S3 - KEYINT2 - GPN1 */
#define GPN2_IN		(~0x000030)	/* xxxx xxxx xxxx xxxx xxxx 1111 1100 1111 */  /* S4 - KEYINT3 - GPN2 */
#define GPN3_IN		(~0x0000C0)	/* xxxx xxxx xxxx xxxx xxxx 1111 0011 1111 */  /* S5 - KEYINT4 - GPN3 */
#define GPN4_IN		(~0x030000)	/* xxxx xxxx xxxx xxxx xxxx 1100 1111 1111 */  /* S6 - KEYINT5 - GPN4 */
#define GPN5_IN		(~0xC00000)	/* xxxx xxxx xxxx xxxx xxxx 0011 1111 1111 */  /* S7 - KEYINT6 - GPN5 */

int main(void)
{
	unsigned char key = 0;

	/* init led related register(GPMCON, GPMDAT) */
	GPMDAT = (GPMDAT & (~0x0F)) | 0x0F;
	GPMCON = (GPMCON & (~0xFFFF)) | GPM0_OUT | GPM1_OUT | GPM2_OUT | GPM3_OUT;

	/* init key related register(GPNCON, GPNDAT) */
	GPNCON = (GPNCON | (~0xFFF)) & GPN0_IN  & GPN1_IN & GPN2_IN & GPN3_IN;

	for(;;) {
		key = GPNDAT & 0x0F;						 /* GPNDAT0/1/2/3 -- s2/3/4/5 */
		if(key) {
			switch(key) {
				case 0xE: GPMDAT = (GPMDAT & 0xF0) | 0xE; break; /* 1110 */
				case 0xD: GPMDAT = (GPMDAT & 0xF0) | 0xD; break; /* 1101 */
				case 0xB: GPMDAT = (GPMDAT & 0xF0) | 0xB; break; /* 1011 */
				case 0x7: GPMDAT = (GPMDAT & 0xF0) | 0x7; break; /* 0111 */
//				default:  GPMDAT = (GPMDAT & 0xF0);       break; /* 0000 */
				default:  break;
			}
		} else {
			GPMDAT = (GPMDAT & 0xF0) | 0xF; 			 /* 0000 */
		}
	}
}
